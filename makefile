PACKAGE=zt-router
VERSION=1.0
ARCH=all

all:
	mkdir -p build/DEBIAN
	cp -r debian/control debian/postinst build/DEBIAN/
	chmod 0755 build/DEBIAN/postinst

	mkdir -p build/etc
	cp etc/zt-router.conf build/etc/

	mkdir -p build/usr/local/bin
	cp usr/local/bin/zt-router.sh build/usr/local/bin/

	mkdir -p build/etc/systemd/system
	cp debian/zt-router.service build/etc/systemd/system/

	dpkg-deb --build build $(PACKAGE)_$(VERSION)_$(ARCH).deb
