# gitwrap
Bash wrapper function for git for convenient setting of author on shared login accounts (root, application ids, etc.)

Git by default is geared toward use on a dedicated user account/system. It does not play nicely with use on a single
account - such as when logged in or su'd to root, or to a common/shared application/service account. 

While some would argue against this usage, it exists, and is common practice. This script is designed 
to make it easier to use git in those circumstances. 

Overall design - git command will be wrapped with a bash function and alias - so that use is transparent. 
The function will look at the git configuration, and environment, to try and set a suitable default. If the
active configuration in current repo or global specifies a user name and email, it will do nothing. If on the 
other hand, there is no user name/email configured, it will attempt to calculate an appropriate default, looking at
the following sources of information:

  * If system is kerberos enabled, will look at current credentials cache and assign the author name and email based
    on the authenticated principal, under the assumption that user will have authenticated as themselves to get to
    the root account.

  * If there is an SSH agent connection established, it will look at the descriptions on the keys, and use the first
    one that looks like an email address as the identity.

  * Potentially - look at who -u based on current tty and extract the source host, and then use current userid @ 
    remote host. 
