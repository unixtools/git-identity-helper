VERSION=1.1.0

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