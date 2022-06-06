QUICTLS_VERSION = OpenSSL_1_1_1o
QUICTLS_SOURCES = https://codeload.github.com/quictls/openssl/tar.gz/$(QUICTLS_VERSION)+quic
QUICTLS_TARBALL = quictls-$(QUICTLS_VERSION).tar.gz
QUICTLS_BUILDIR = src
QUICTLS_DESTDIR = dist
QUICTLS_DESTDIR_ABS = $(shell realpath $(QUICTLS_DESTDIR))
QUICTLS_ARCHIVE = quictls-$(QUICTLS_VERSION)-dist.tar.gz

all: $(QUICTLS_DESTDIR) $(QUICTLS_ARCHIVE)

$(QUICTLS_BUILDIR):
	@if ! [ -d "$(QUICTLS_BUILDIR)" ]; then mkdir -v "$(QUICTLS_BUILDIR)"; fi

$(QUICTLS_BUILDIR)/quictls-$(QUICTLS_VERSION).tar.gz: $(QUICTLS_BUILDIR)
	curl -sSL -o "$(QUICTLS_TARBALL)" "$(QUICTLS_SOURCES)"

build: $(QUICTLS_BUILDIR)/quictls-$(QUICTLS_VERSION).tar.gz
	tar -C $(QUICTLS_BUILDIR) --strip-components=1 -xf "$(QUICTLS_TARBALL)"
	cd "$(QUICTLS_BUILDIR)" && ./config --prefix="/opt/quictls" --openssldir="/opt/quictls" no-shared
	$(MAKE) -C "$(QUICTLS_BUILDIR)" -j "$(shell nproc)"
	ldd "$(QUICTLS_BUILDIR)/apps/openssl" || true
	"$(QUICTLS_BUILDIR)/apps/openssl" version

$(QUICTLS_DESTDIR): build
	if ! [ -d "$(QUICTLS_DESTDIR)" ]; then mkdir -v "$(QUICTLS_DESTDIR)"; fi
	$(MAKE) -C "$(QUICTLS_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(QUICTLS_DESTDIR_ABS)" install_sw

# Take a moment to hate on how fucking shit the `tar` CLI is with me, especially regarding the awkward dance of path prefixes. Press S.
$(QUICTLS_ARCHIVE): $(QUICTLS_DESTDIR)
	tar -C "$(QUICTLS_DESTDIR)" -cjf "$(QUICTLS_ARCHIVE)" "opt"

clean:
	rm -rf "$(QUICTLS_BUILDIR)"
	rm -rf "$(QUICTLS_DESTDIR)"
	rm -rf "$(QUICTLS_TARBALL)"
	rm -fv "$(QUICTLS_ARCHIVE)"

.PHONY: clean build
