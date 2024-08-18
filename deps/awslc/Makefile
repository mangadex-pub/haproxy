AWSLC_VERSION = 1.33.0
BUILD_VERSION_REPOSHA = $(shell git rev-parse --short HEAD)
AWSLC_BUILD_VERSION = mangadex-$(BUILD_VERSION_REPOSHA)
AWSLC_TAG = $(AWSLC_VERSION)

AWSLC_SOURCES = https://github.com/aws/aws-lc/archive/refs/tags/v$(AWSLC_VERSION).tar.gz
AWSLC_TARBALL = awslc-$(AWSLC_VERSION).tar.gz
AWSLC_BUILDIR = src
AWSLC_DESTDIR = dist
AWSLC_DESTDIR_ABS = $(shell realpath $(AWSLC_DESTDIR))
AWSLC_ARCHIVE = awslc-dist.tar.gz
AWSLC_PREFIX_DIR = /opt
AWSLC_PREFIX = $(AWSLC_PREFIX_DIR)/awslc

all: build $(AWSLC_DESTDIR) $(AWSLC_ARCHIVE)

$(AWSLC_TARBALL):
	curl -sfSL -o "$(AWSLC_TARBALL)" "$(AWSLC_SOURCES)"

$(AWSLC_BUILDIR): $(AWSLC_TARBALL)
	@if ! [ -d "$(AWSLC_BUILDIR)" ]; then mkdir -v "$(AWSLC_BUILDIR)"; fi
	tar -C $(AWSLC_BUILDIR) --strip-components=1 -xf "$(AWSLC_TARBALL)"

build: $(AWSLC_BUILDIR)
	sed -i 's/^#define AWSLC_VERSION_NUMBER_STRING .+$\/#define AWSLC_VERSION_NUMBER_STRING "$(AWSLC_VERSION)+$(AWSLC_BUILD_VERSION)"/g' "$(AWSLC_BUILDIR)/include/openssl/base.h"
	cmake --version
	cmake \
		-S $(AWSLC_BUILDIR) \
		-B $(AWSLC_BUILDIR)/build \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_STANDARD=11 \
		-DCMAKE_INSTALL_PREFIX=$(AWSLC_DESTDIR_ABS)$(AWSLC_PREFIX) \
		-DCMAKE_INSTALL_LIBDIR="lib" \
		-DBUILD_SHARED_LIBS=FALSE \
		-DDISABLE_GO=TRUE \
		-DDISABLE_PERL=TRUE \
		-DBUILD_TESTING=FALSE
	make -C $(AWSLC_BUILDIR)/build -j$(shell nproc)
	$(AWSLC_BUILDIR)/build/tool/bssl version
	ldd $(AWSLC_BUILDIR)/build/tool/bssl

$(AWSLC_DESTDIR): build
	@if ! [ -d "$(AWSLC_DESTDIR)" ]; then mkdir -v "$(AWSLC_DESTDIR)"; fi
	make -C $(AWSLC_BUILDIR)/build install -j$(shell nproc)
	$(AWSLC_DESTDIR_ABS)$(AWSLC_PREFIX)/bin/bssl version

$(AWSLC_ARCHIVE): $(AWSLC_DESTDIR)
	tar -C "$(AWSLC_DESTDIR)" -cjf "$(AWSLC_ARCHIVE)" "$(shell ls -1 $(AWSLC_DESTDIR) | head -n1)"

clean:
	rm -rf "$(AWSLC_BUILDIR)"
	rm -rf "$(AWSLC_DESTDIR)"
	rm -fv "$(AWSLC_ARCHIVE)"

.PHONY: clean build
