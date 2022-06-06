PCRE2_VERSION = 10.40
PCRE2_SOURCES = https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(PCRE2_VERSION)/pcre2-$(PCRE2_VERSION).tar.gz
PCRE2_TARBALL = pcre2-$(PCRE2_VERSION).tar.gz
PCRE2_BUILDIR = src
PCRE2_DESTDIR = dist
PCRE2_DESTDIR_ABS = $(shell realpath $(PCRE2_DESTDIR))
PCRE2_ARCHIVE = pcre2-dist.tar.gz

all: build dist

$(PCRE2_BUILDIR):
	@if ! [ -d "$(PCRE2_BUILDIR)" ]; then mkdir -v "$(PCRE2_BUILDIR)"; fi

$(PCRE2_BUILDIR)/pcre2-$(PCRE2_VERSION).tar.gz: $(PCRE2_BUILDIR)
	curl -sSL -o "$(PCRE2_TARBALL)" "$(PCRE2_SOURCES)"

build: $(PCRE2_BUILDIR)/pcre2-$(PCRE2_VERSION).tar.gz
	tar -C $(PCRE2_BUILDIR) --strip-components=1 -xf "$(PCRE2_TARBALL)"
	if [ -f "$(PCRE2_BUILDIR)/CmakeCache.txt" ]; then rm -v "$(PCRE2_BUILDIR)/CmakeCache.txt"; fi
	cd "$(PCRE2_BUILDIR)" && cmake -DPCRE2_STATIC_PIC=ON -DPCRE2_SUPPORT_JIT=ON -DCMAKE_INSTALL_PREFIX="$(PCRE2_DESTDIR_ABS)" . && make

$(PCRE2_DESTDIR): build
	if ! [ -d "$(PCRE2_DESTDIR)" ]; then mkdir -v "$(PCRE2_DESTDIR)"; fi
	cd "$(PCRE2_BUILDIR)" && make install

$(PCRE2_ARCHIVE): $(PCRE2_DESTDIR)
	tar -C "$(PCRE2_DESTDIR)" -cjf "$(PCRE2_ARCHIVE)" $$(ls -1 $(PCRE2_DESTDIR))

clean:
	rm -rf "$(PCRE2_BUILDIR)"
	rm -rf "$(PCRE2_DESTDIR)"
	rm -fv "$(PCRE2_TARBALL)"
	rm -fv "$(PCRE2_ARCHIVE)"

.PHONY: clean build
