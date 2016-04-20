/*
 *
 * Project: git-identity-helper
 * Web: https://github.com/unixtools/git-identity-helper
 * License: Perl Artistic License and LGPL or contact author
 * Author: nneul@neulinger.org
 *
 */

#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/stat.h>
#include <ctype.h>
#include <glib.h>

#define MAXBUF 128000

char *gitpath = NULL;
unsigned char debug = 0;

void run_git(char *gitpath, char *argv[])
{
	argv[0] = gitpath;
	if (debug) {
		fprintf(stderr, "Launching git.\n");
	}
	execv(gitpath, argv);
	exit(1);
}

char *expand_at(char *in)
{
	int cnt = 0;
	int i;

	for (i = 0; i <= strlen(in); i++) {
		if (in[i] == '@') {
			cnt++;
		}
	}

	int len = strlen(in) + cnt * 3 + 1;
	char *output = calloc(len, 1);

	int j = 0;
	for (i = 0; i <= strlen(in); i++) {
		if (in[i] != '@') {
			output[j++] = in[i];
		} else {
			output[j++] = ' ';
			output[j++] = 'a';
			output[j++] = 't';
			output[j++] = ' ';
		}
	}
	return (output);
}

char *backticks(char *cmd)
{
	FILE *tmpf;
	char *output = calloc(MAXBUF, 1);

	if (!cmd || !cmd[0]) {
		if (debug) {
			fprintf(stderr, "No command specified for backticks function!\n");
		}
		return ("");
	}

	if (!(tmpf = popen(cmd, "r"))) {
		fprintf(stderr, "Failed to open sub command (%s)!\n", cmd);
		return ("");
	}

	int cnt = fread(output, MAXBUF, 1, tmpf);
	fclose(tmpf);

	if (debug) {
		fprintf(stderr, "Returning (%s) from sub command (%s).\n", output, cmd);
	}

	return (output);
}

int main(int argc, char *argv[])
{
	char *path = strdup(getenv("PATH"));
	char *dir;
	char *tmpfname;
	int len;
	int res;
	int i, j;
	struct stat ts;

	if (getenv("GIT_IDENTITY_HELPER_DEBUG")) {
		debug = 1;
	}

	for (dir = strtok(path, ":"); dir; dir = strtok(NULL, ":")) {
		if (strstr(dir, "/git-identity-helper")) {
			continue;
		}

		len = strlen(dir) + 5;
		tmpfname = calloc(len, 1);
		assert(tmpfname != NULL);

		snprintf(tmpfname, len, "%s/git", dir);
		if (debug) {
			fprintf(stderr, "Checking for: %s\n", tmpfname);
		}

		res = stat(tmpfname, &ts);
		if (!res) {
			gitpath = tmpfname;
			if (debug) {
				printf("found git: %s\n", gitpath);
			}
			break;
		}

		free(tmpfname);
		tmpfname = NULL;
	}

	/* Must have a path for git executable */
	if (!gitpath) {
		fprintf(stderr, "Could not locate git executable!\n");
		exit(1);
	}

	/* Temporary command */
	FILE *tmpf;
	int cmdlen = strlen(gitpath) + 100;
	char *cmd = calloc(cmdlen, 1);
	if (!cmd) {
		fprintf(stderr, "Memory allocation for tmp cmd failed!\n");
		exit(1);
	}

	/*
	 * Try with hard configured from .git/config or ~/.gitconfig first
	 */
	snprintf(cmd, cmdlen, "%s config --get user.name 2>&1", gitpath);
	char *git_conf_user = backticks(cmd);
	for (i = 0; i <= strlen(git_conf_user); i++) {
		if (git_conf_user[i] == '\r' || git_conf_user[i] == '\n') {
			git_conf_user[i] = '\0';
		}
	}
	if (debug) {
		fprintf(stderr, "Current git config user.name: '%s'\n", git_conf_user);
	}

	snprintf(cmd, cmdlen, "%s config --get user.email 2>&1", gitpath);
	char *git_conf_email = backticks(cmd);
	for (i = 0; i <= strlen(git_conf_email); i++) {
		if (git_conf_email[i] == '\r' || git_conf_email[i] == '\n') {
			git_conf_email[i] = '\0';
		}
	}
	if (debug) {
		fprintf(stderr, "Current git config user.email: '%s'\n", git_conf_email);
	}

	if (strlen(git_conf_user) > 0 && strlen(git_conf_email) > 0) {
		if (debug) {
			fprintf(stderr, "name/email set in configuration\n");
		}
		run_git(gitpath, argv);
	}

	/* Check for environment settings */
	if (getenv("GIT_AUTHOR_NAME") && getenv("GIT_AUTHOR_EMAIL")) {
		if (debug) {
			fprintf(stderr, "name/email already set in environment\n");
		}
		run_git(gitpath, argv);
	}

	/* Try to load from kerberos credentials */
	char *git_krb_email = backticks("klist 2>&1 | grep 'Default principal:' | awk '{ print $3 }'");
	git_krb_email = g_ascii_strdown(git_krb_email, -1);
	for (i = 0; i <= strlen(git_krb_email); i++) {
		if (git_krb_email[i] == '\r' || git_krb_email[i] == '\n') {
			git_krb_email[i] = '\0';
		}
	}
	if (debug) {
		fprintf(stderr, "user from kerberos: %s\n", git_krb_email);
	}

	if (strlen(git_krb_email) > 0) {
		char *git_krb_name = expand_at(git_krb_email);
		if (debug) {
			fprintf(stderr, "name from kerberos: %s\n", git_krb_name);
		}

		if (strlen(git_krb_email) > 0 && strlen(git_krb_name) > 0) {
			int maxlen = strlen(git_krb_name) + 30;
			char *buf1 = calloc(maxlen, 1);
			char *buf2 = calloc(maxlen, 1);
			char *buf3 = calloc(maxlen, 1);
			char *buf4 = calloc(maxlen, 1);

			snprintf(buf1, maxlen, "GIT_AUTHOR_EMAIL=%s", git_krb_email);
			snprintf(buf2, maxlen, "GIT_COMMITTER_EMAIL=%s", git_krb_email);
			snprintf(buf3, maxlen, "GIT_AUTHOR_NAME=%s", git_krb_name);
			snprintf(buf4, maxlen, "GIT_COMMITTER_NAME=%s", git_krb_name);

			putenv(buf1);
			putenv(buf2);
			putenv(buf3);
			putenv(buf4);

			run_git(gitpath, argv);
		}
	}

	if (getenv("SSH_AUTH_SOCK")) {

		char *git_ssh_email = backticks("ssh-add -l 2>&1 | awk '{ print $3 }' | grep '@' | head -1");
		git_ssh_email = g_ascii_strdown(git_ssh_email, -1);
		for (i = 0; i <= strlen(git_ssh_email); i++) {
			if (git_ssh_email[i] == '\r' || git_ssh_email[i] == '\n') {
				git_ssh_email[i] = '\0';
			}
		}
		if (debug) {
			fprintf(stderr, "user from ssh: %s\n", git_ssh_email);
		}

		if (strlen(git_ssh_email) > 0) {
			char *git_ssh_name = expand_at(git_ssh_email);
			if (debug) {
				fprintf(stderr, "name from ssh: %s\n", git_ssh_name);
			}

			if (strlen(git_ssh_email) > 0 && strlen(git_ssh_name) > 0) {
				int maxlen = strlen(git_ssh_name) + 30;
				char *buf1 = calloc(maxlen, 1);
				char *buf2 = calloc(maxlen, 1);
				char *buf3 = calloc(maxlen, 1);
				char *buf4 = calloc(maxlen, 1);

				snprintf(buf1, maxlen, "GIT_AUTHOR_EMAIL=%s", git_ssh_email);
				snprintf(buf2, maxlen, "GIT_COMMITTER_EMAIL=%s", git_ssh_email);
				snprintf(buf3, maxlen, "GIT_AUTHOR_NAME=%s", git_ssh_name);
				snprintf(buf4, maxlen, "GIT_COMMITTER_NAME=%s", git_ssh_name);

				putenv(buf1);
				putenv(buf2);
				putenv(buf3);
				putenv(buf4);

				run_git(gitpath, argv);
			}
		}

	}

	/* Fall back at the end and just run git normally */
	if (debug) {
		fprintf(stderr, "falling back to default git behavior\n");
	}
	run_git(gitpath, argv);
	return 0;
}

/* 
vim: set expandtab: ts=4
*/
