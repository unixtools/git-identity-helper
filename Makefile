VERSION=1.2.0
TOP=`pwd`

all:

install:
	mkdir -p $(DESTDIR)/etc/profile.d
	cp git-identity-helper.sh $(DESTDIR)/etc/profile.d/git-identity-helper.sh

dist:
	rm -rf /tmp/git-identity-helper-$(VERSION)
	mkdir /tmp/git-identity-helper-$(VERSION)
	cp -pr . /tmp/git-identity-helper-$(VERSION)
	cd /tmp/git-identity-helper-$(VERSION) && rm -rf *.gz .git .gitignore
	tar -C/tmp -czvf ../git-identity-helper-$(VERSION).tar.gz git-identity-helper-$(VERSION)
	rm -rf /tmp/git-identity-helper-$(VERSION)

deb: dist
	cp ../git-identity-helper-$(VERSION).tar.gz ../git-identity-helper_$(VERSION).orig.tar.gz
	dpkg-buildpackage
	rm ../git-identity-helper_$(VERSION).orig.tar.gz

rpm: dist
	rm -rf rpmtmp
	mkdir -p rpmtmp/SOURCES rpmtmp/SPECS rpmtmp/BUILD rpmtmp/RPMS rpmtmp/SRPMS
	cp ../git-identity-helper-$(VERSION).tar.gz rpmtmp/SOURCES/
	rpmbuild -ba -D "_topdir $(TOP)/rpmtmp" \
		-D "_builddir $(TOP)/rpmtmp/BUILD" \
		-D "_rpmdir $(TOP)/rpmtmp/RPMS" \
		-D "_sourcedir $(TOP)/rpmtmp/SOURCES" \
		-D "_specdir $(TOP)/rpmtmp/SPECS" \
		-D "_srcrpmdir $(TOP)/rpmtmp/SRPMS" \
		rpm/git-identity-helper.spec
	cp $(TOP)/rpmtmp/RPMS/noarch/* ../
	cp $(TOP)/rpmtmp/SRPMS/* ../
	rm -rf rpmtmp
