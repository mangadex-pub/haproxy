VTEST_GITREF = 35b5cae9d8cdd64be07a737449aecde839741c1e
VTEST_SOURCES = https://github.com/vtest/VTest/archive/$(VTEST_GITREF).zip
VTEST_ZIPBALL = VTest-$(VTEST_GITREF).zip
VTEST_BUILDIR = src
VTEST_DESTDIR = dist
VTEST_ARCHIVE = vtest-dist.tar.gz

all: build $(VTEST_DESTDIR) $(VTEST_ARCHIVE)

$(VTEST_ZIPBALL):
	curl -sfSL -o "$(VTEST_ZIPBALL)" "$(VTEST_SOURCES)"

$(VTEST_BUILDIR): $(VTEST_ZIPBALL)
	unzip "$(VTEST_ZIPBALL)" -d .
	mv -v "VTest-$(VTEST_GITREF)" "$(VTEST_BUILDIR)"

build: $(VTEST_BUILDIR)
	$(MAKE) build_$(shell uname -s)

.PHONY: build_Darwin
build_Darwin:
	$(MAKE) -C "$(VTEST_BUILDIR)" -j "$(shell nproc)" \
		INCS="-Isrc -Ilib -I$$(brew --prefix pcre2)/include -pthread" \
		LIBS="-L$$(brew --prefix pcre2)/lib -lm -lpcre2-8 -lz"

.PHONY: build_Linux
build_Linux: $(VTEST_BUILDIR)
	$(MAKE) -C "$(VTEST_BUILDIR)" -j "$(shell nproc)"

$(VTEST_DESTDIR): build
	if ! [ -d "$(VTEST_DESTDIR)" ]; then mkdir -v "$(VTEST_DESTDIR)"; fi
	cp -fv "$(VTEST_BUILDIR)/vtest" "$(VTEST_DESTDIR)/vtest"
	chmod -v +x "$(VTEST_DESTDIR)/vtest"

$(VTEST_ARCHIVE): $(VTEST_DESTDIR)
	tar -C "$(VTEST_DESTDIR)" -cjf "$(VTEST_ARCHIVE)" "."

clean:
	rm -fv "$(VTEST_ZIPBALL)"
	rm -rf "$(VTEST_BUILDIR)"
	rm -rf "$(VTEST_DESTDIR)"
	rm -rf "$(VTEST_ARCHIVE)"

.PHONY: clean build
