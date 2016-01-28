#
# Project: git-identity-helper
# Web: https://github.com/unixtools/git-identity-helper
# License: Perl Artistic License and LGPL or contact author
# Author: nneul@neulinger.org
#

case ":${PATH:-}:" in
    *:/usr/lib/git-identity-helper:*) ;;
    *) PATH="/usr/lib/git-identity-helper${PATH:+:$PATH}" ;;
esac

# vim: set expandtab: ts=4
