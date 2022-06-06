QUICTLS_VERSION = OpenSSL_1_1_1o
QUICTLS_SOURCES = https://codeload.github.com/quictls/openssl/tar.gz/$(QUICTLS_VERSION)+quic
QUICTLS_TARBALL = quictls-$(QUICTLS_VERSION).tar.gz
QUICTLS_DESTDIR = dist
QUICTLS_DESTDIR_ABS = $(shell realpath $(QUICTLS_DESTDIR))
QUICTLS_ARCHIVE = quictls-$(QUICTLS_VERSION)-dist.tar.gz

all: build $(QUICTLS_DESTDIR) archive

src:
	if ! [ -d "src" ]; then mkdir -v "src"; fi

src/quictls-$(QUICTLS_VERSION).tar.gz: src
	curl -sSL -o "$(QUICTLS_TARBALL)" "$(QUICTLS_SOURCES)"

build: src/quictls-$(QUICTLS_VERSION).tar.gz
	tar -C src --strip-components=1 -xf "$(QUICTLS_TARBALL)"
	cd "src" && ./config --prefix="/opt/quictls" --openssldir="/opt/quictls" no-shared
	$(MAKE) -C "src" -j "$(shell nproc)"
	ldd "src/apps/openssl" || true
	src/apps/openssl version

$(QUICTLS_DESTDIR):
	if ! [ -d "$(QUICTLS_DESTDIR)" ]; then mkdir -v "$(QUICTLS_DESTDIR)"; fi
	$(MAKE) -C "src" -j "$(shell nproc)" DESTDIR="$(QUICTLS_DESTDIR_ABS)" install_sw

# Take a moment to hate on how fucking shit the `tar` CLI is with me, especially regarding the awkward dance of path prefixes. Press S.
archive: $(QUICTLS_DESTDIR)
	tar -C "$(QUICTLS_DESTDIR)" -cjf "$(QUICTLS_ARCHIVE)" "opt"

clean:
	@rm -rf "src" || true
	@rm -rf "$(QUICTLS_TARBALL)" || true
	@rm -rf "$(QUICTLS_DESTDIR)" || true
	@rm -v "$(QUICTLS_ARCHIVE)" || true

.PHONY: clean build $(QUICTLS_DESTDIR) dist archive
