OPENSSL_VERSION = 1.1.1q
BUILD_VERSION_REPOSHA = $(shell git rev-parse --short HEAD)
QUICTLS_BUILD_VERSION = quic-mangadex-$(BUILD_VERSION_REPOSHA)
QUICTLS_TAG = OpenSSL_$(subst .,_,$(OPENSSL_VERSION))+quic1

QUICTLS_SOURCES = https://codeload.github.com/quictls/openssl/tar.gz/$(QUICTLS_TAG)
QUICTLS_TARBALL = quictls-$(OPENSSL_VERSION).tar.gz
QUICTLS_BUILDIR = src
QUICTLS_DESTDIR = dist
QUICTLS_DESTDIR_ABS = $(shell realpath $(QUICTLS_DESTDIR))
QUICTLS_ARCHIVE = quictls-dist.tar.gz

all: build $(QUICTLS_DESTDIR) $(QUICTLS_ARCHIVE)

$(QUICTLS_TARBALL):
	curl -sfS -o "$(QUICTLS_TARBALL)" "$(QUICTLS_SOURCES)"

$(QUICTLS_BUILDIR): $(QUICTLS_TARBALL)
	@if ! [ -d "$(QUICTLS_BUILDIR)" ]; then mkdir -v "$(QUICTLS_BUILDIR)"; fi
	tar -C $(QUICTLS_BUILDIR) --strip-components=1 -xf "$(QUICTLS_TARBALL)"

build: $(QUICTLS_BUILDIR)
	cd "$(QUICTLS_BUILDIR)" &&  sed -i 's/^# define OPENSSL_VERSION_TEXT.*$\/# define OPENSSL_VERSION_TEXT "OpenSSL $(OPENSSL_VERSION)+$(QUICTLS_BUILD_VERSION) $(shell date -u +'%e %b %Y')"/g' "include/openssl/opensslv.h"
	cd "$(QUICTLS_BUILDIR)" && CC=cc ./config --prefix="/opt/quictls" --openssldir="/opt/quictls" --libdir="lib" no-shared
	$(MAKE) -C "$(QUICTLS_BUILDIR)" -j "$(shell nproc)" VERSION=$(OPENSSL_VERSION)+quic-mangadex-$(BUILD_VERSION_REPOSHA)
	"$(QUICTLS_BUILDIR)/apps/openssl" version
	$(MAKE) buildinfo_$(shell uname -s)

.PHONY: buildinfo_Linux
buildinfo_Linux:
	@echo "Checking shared libraries openssl is linked against (Linux):"
	@ldd "$(QUICTLS_BUILDIR)/apps/openssl" || true

.PHONY: buildinfo_Darwin
buildinfo_Darwin:
	@echo "Checking shared libraries openssl is linked against (Darwin):"
	@otool -L "$(QUICTLS_BUILDIR)/apps/openssl" || true

$(QUICTLS_DESTDIR): build
	@if ! [ -d "$(QUICTLS_DESTDIR)" ]; then mkdir -v "$(QUICTLS_DESTDIR)"; fi
	$(MAKE) -C "$(QUICTLS_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(QUICTLS_DESTDIR_ABS)" install_sw
	$(QUICTLS_DESTDIR_ABS)/opt/quictls/bin/openssl version

$(QUICTLS_ARCHIVE): $(QUICTLS_DESTDIR)
	tar -C "$(QUICTLS_DESTDIR)" -cjf "$(QUICTLS_ARCHIVE)" "opt"

clean:
	rm -fv "$(QUICTLS_TARBALL)"
	rm -rf "$(QUICTLS_BUILDIR)"
	rm -rf "$(QUICTLS_DESTDIR)"
	rm -fv "$(QUICTLS_ARCHIVE)"

.PHONY: clean build
