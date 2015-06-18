#!/bin/sh

. ./git-identity-helper.sh

git status


TMPREPO=`mktemp -d`
if [ "$TMPREPO" = "" ]; then
	echo "Failed to create tmp repo."
	exit
fi

pushd `pwd`
cd $TMPREPO || exit

set -x

git init
cal > test.txt
git add test.txt
git commit -m "test" test.txt
git show

popd
rm -rf $TMPREPO
