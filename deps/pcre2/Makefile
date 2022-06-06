PCRE2_VERSION = 10.40
PCRE2_SOURCES = https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(PCRE2_VERSION)/pcre2-$(PCRE2_VERSION).tar.gz
PCRE2_TARBALL = pcre2-$(PCRE2_VERSION).tar.gz

PCRE2_DESTDIR = dist
PCRE2_DESTDIR_ABS = $(shell realpath $(PCRE2_DESTDIR))

all: build dist

src:
	if ! [ -d "src" ]; then mkdir -v "src"; fi

src/pcre2-$(PCRE2_VERSION).tar.gz: src
	curl -sSL -o "$(PCRE2_TARBALL)" "$(PCRE2_SOURCES)"

build: src/pcre2-$(PCRE2_VERSION).tar.gz
	tar -C src --strip-components=1 -xf "$(PCRE2_TARBALL)"
	if [ -f "src/CmakeCache.txt" ]; then rm -v "src/CmakeCache.txt"; fi
	cd "src" && cmake -DPCRE2_STATIC_PIC=ON -DPCRE2_SUPPORT_JIT=ON -DCMAKE_INSTALL_PREFIX="$(PCRE2_DESTDIR_ABS)" . && make

dist: build
	if ! [ -d "$(PCRE2_DESTDIR)" ]; then mkdir -v "$(PCRE2_DESTDIR)"; fi
	cd "src" && make install

clean:
	rm -rf "src"

.PHONY: clean build dist
