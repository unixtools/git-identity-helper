#
# Project: git-identity-helper
# Web: https://github.com/unixtools/git-identity-helper
# License: Perl Artistic License and LGPL or contact author
# Author: nneul@neulinger.org
#

debug=0

if [ -e /usr/bin/git ]; then
    gitpath=/usr/bin/git
elif [ -e /bin/git ]; then
    gitpath=/bin/git
fi
if [ "$gitpath" = "" ]; then
    echo "Couldn't find git."
    exit 1
fi

# Check if any configuration is set for current repo or globally
gitid_cfg_name=`$gitpath config --get user.name`
gitid_cfg_email=`$gitpath config --get user.email`
if [ "$gitid_cfg_name" != "" -a "$gitid_cfg_email" != "" ]; then
    [ $debug != 0 ] && echo "name/email set in configuration"
    exec $gitpath "${@}"
fi

# If git author name and email env vars already set, pass through as is
# This would be useful if they were passed through from client ssh or similar
if [ "$GIT_AUTHOR_NAME" != "" -a "$GIT_AUTHOR_EMAIL" != "" ]; then
    [ $debug != 0 ] && echo "name/email already set in environment"
    exec $gitpath "${@}"
fi

gitid_krb_user=`klist 2>&1 | grep "Default principal:" | awk '{ print $3 }' | tr A-Z a-z`
gitid_krb_name=`echo "$gitid_krb_user" | sed "s/@/ at /"`
if [ "$gitid_krb_user" != "" ]; then
    [ $debug != 0 ] && echo "name/email set via krb5 creds"
    (
        export GIT_AUTHOR_EMAIL="$gitid_krb_user"
        export GIT_AUTHOR_NAME="$gitid_krb_name"
        export GIT_COMMITTER_EMAIL="$gitid_krb_user"
        export GIT_COMMITTER_NAME="$gitid_krb_name"
        exec $gitpath "${@}"
    )
fi

if [ "$SSH_AUTH_SOCK" != "" ]; then
    gitid_ssh_user=`ssh-add -l 2>&1 | awk '{ print $3 }' | grep "@" | head -1`
    gitid_ssh_name=`echo "$gitid_ssh_user" | sed "s/@/ on /"`
    if [ "$gitid_ssh_user" != "" ]; then
        [ $debug != 0 ] && echo "name/email set via ssh key description"
        (
            export GIT_AUTHOR_EMAIL="$gitid_ssh_user"
            export GIT_AUTHOR_NAME="$gitid_ssh_name"
            export GIT_COMMITTER_EMAIL="$gitid_ssh_user"
            export GIT_COMMITTER_NAME="$gitid_ssh_name"
            exec $gitpath "${@}"
        )
    fi
fi

[ $debug != 0 ] && echo "falling back to git default behavior"
exec $gitpath "${@}"

# vim: set expandtab: ts=4
