VERSION=2.0.1
TOP=`pwd`

all: git-wrapper

git-wrapper: git-wrapper.c
	gcc -o git-wrapper git-wrapper.c `pkg-config --cflags glib-2.0` `pkg-config --libs glib-2.0`

install:
	mkdir -p $(DESTDIR)/etc/profile.d
	mkdir -p $(DESTDIR)/usr/lib/git-identity-helper
	cp git-identity-helper.sh $(DESTDIR)/etc/profile.d/git-identity-helper.sh
	cp git-wrapper.sh $(DESTDIR)/usr/lib/git-identity-helper/git
	chmod 755 $(DESTDIR)/usr/lib/git-identity-helper/git

dist:
	rm -rf /tmp/git-identity-helper-$(VERSION)
	mkdir /tmp/git-identity-helper-$(VERSION)
	cp -pr . /tmp/git-identity-helper-$(VERSION)
	cd /tmp/git-identity-helper-$(VERSION) && rm -rf *.gz .git .gitignore
	tar -C/tmp -czvf ../git-identity-helper-$(VERSION).tar.gz git-identity-helper-$(VERSION)
	rm -rf /tmp/git-identity-helper-$(VERSION)

deb: dist
	cp ../git-identity-helper-$(VERSION).tar.gz ../git-identity-helper_$(VERSION).orig.tar.gz
	dpkg-buildpackage -us -uc
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
