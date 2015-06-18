# gitwrap
Bash wrapper function for git for convenient setting of author on shared login accounts (root, application ids, etc.)

Git by default is geared toward use on a dedicated user account/system. It does not play nicely with use on a single
account - such as when logged in or su'd to root, or to a common/shared application/service account. 

While some would argue against this usage, it exists, and is common practice. This script is designed 
to make it easier to use git in those circumstances. 

Intent is that this script would be dropped into /etc/profile.d/ to apply to all users on a given system.

Overall design - git command will be wrapped with a bash function which will transparently pre-compute a better
default setting for git author name and email if one isn't already set in per-repo or global configuration.

The function will look at the git configuration, and environment, to try and set a suitable default. If the
active configuration in current repo or global specifies a user name and email, it will do nothing. If on the 
other hand, there is no user name/email configured, it will attempt to calculate an appropriate default, looking at
the following sources of information:

  * If system is kerberos enabled, will look at current credentials cache and assign the author name and email based
    on the authenticated principal, under the assumption that user will have authenticated as themselves to get to
    the root account.

  * If there is an SSH agent connection established, it will look at the descriptions on the keys, and use the first
    one that looks like an email address as the identity.

  * (NOT YET) - look at who -u based on current tty and extract the source host, and then use current userid @ 
    remote host. (Not sure this one is all that useful.)

  * (NOT YET) - allow defining a table of source hosts if you have a consistent host:author mapping. Look up
    in that table info from who -u or SSH_CLIENT / SSH_CONNECTION to obtain the author name. 

  * Lastly, fall back to just executing git as is without setting any id in the environment. 

In any of the above cases, will initial default to just using email address as both userid and name. It may 
be worth trying to look up the userid portion of the email in passwd file, but I don't think that will typically 
match up often enough to be worthwhile. 


Additional Ideas:
	Env var to request "prompting" - i.e. never allow it to use default behavior
	Apply checks only on certain git operations?
