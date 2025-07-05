PACKAGE := zt-router
VERSION := 1.0
ARCH    := all
BUILD   := build
DEB     := $(PACKAGE)_$(VERSION)_$(ARCH).deb

.PHONY: all clean prep

all: $(DEB)

$(DEB): prep
	dpkg-deb --build $(BUILD) $@

prep:
	rm -rf $(BUILD)
	install -Dm755 usr/local/bin/zt-router.sh $(BUILD)/usr/local/bin/zt-router.sh
	install -Dm644 debian/zt-router.service $(BUILD)/etc/systemd/system/zt-router.service
	install -Dm644 etc/zt-router.conf $(BUILD)/etc/zt-router.conf
	install -Dm644 debian/control $(BUILD)/DEBIAN/control
	install -Dm755 debian/postinst $(BUILD)/DEBIAN/postinst
	install -Dm644 etc/zt-router.conf $(BUILD)/usr/share/doc/zt-router/examples/zt-router.conf

clean:
	rm -rf $(BUILD) $(DEB)
