git () {
	debug=1

	gitpath=""
	if [ -e /usr/bin/git ]; then
		gitpath=/usr/bin/git
    elif [ -e /bin/git ]; then
		gitpath=/bin/git
    fi
	if [ "$gitpath" = "" ]; then
		echo "Couldn't find git."
		return
	fi

	gitid_cfg_name=`$gitpath config --get user.name`
	gitid_cfg_email=`$gitpath config --get user.email`

	if [ "$gitid_cfg_name" != "" -a "$gitid_cfg_email" != "" ]; then
		[ $debug != 0 ] && echo "name/email set in configuration"
		$gitpath ${@}
		return
	fi

	gitid_krb_user=`klist 2>&1 | grep "Default principal:" | awk '{ print $3 }' | tr A-Z a-z`
	gitid_krb_name=`echo "$gitid_krb_user" | sed "s/@/ in /"`
	if [ "$gitid_krb_user" != "" ]; then
		[ $debug != 0 ] && echo "name/email set via krb5 creds"
		export GIT_AUTHOR_EMAIL="$gitid_krb_user"
		export GIT_AUTHOR_NAME="$gitid_krb_name"
		$gitpath ${@}
		return
	fi

	if [ "$SSH_AUTH_SOCK" != "" ]; then
		gitid_ssh_user=`ssh-add -l 2>&1 | awk '{ print $3 }' | grep "@" | head -1 | tr A-Z a-z`
		gitid_ssh_name=`echo "$gitid_ssh_user" | sed "s/@/ on /"`
		if [ "$gitid_ssh_user" != "" ]; then
			[ $debug != 0 ] && echo "name/email set via ssh key description"
			export GIT_AUTHOR_EMAIL="$gitid_ssh_user"
			export GIT_AUTHOR_NAME="$gitid_ssh_name"
			$gitpath ${@}
			return
		fi
	fi

	[ $debug != 0 ] && echo "falling back to git default behavior"
	$gitpath ${@}
	return
}