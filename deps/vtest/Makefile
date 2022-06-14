VTEST_VERSION = master
VTEST_SOURCES = https://codeload.github.com/vtest/vtest/tar.gz/master
VTEST_TARBALL = VTEST-$(VTEST_VERSION).tar.gz
VTEST_BUILDIR = src
VTEST_DESTDIR = dist

all: build $(VTEST_DESTDIR) $(VTEST_DESTDIR)

$(VTEST_TARBALL):
	curl -sfS -o "$(VTEST_TARBALL)" "$(VTEST_SOURCES)"

$(VTEST_BUILDIR): $(VTEST_TARBALL)
	@if ! [ -d "$(VTEST_BUILDIR)" ]; then mkdir -v "$(VTEST_BUILDIR)"; fi
	tar -C $(VTEST_BUILDIR) --strip-components=1 -xf "$(VTEST_TARBALL)"

build: $(VTEST_BUILDIR)
	$(MAKE) -C "$(VTEST_BUILDIR)" -j "$(shell nproc)"

$(VTEST_DESTDIR): build
	if ! [ -d "$(VTEST_DESTDIR)" ]; then mkdir -v "$(VTEST_DESTDIR)"; fi
	cp -fv "$(VTEST_BUILDIR)/vtest" "$(VTEST_DESTDIR)/vtest"
	chmod -v +x "$(VTEST_DESTDIR)/vtest"

clean:
	rm -fv "$(VTEST_TARBALL)"
	rm -rf "$(VTEST_BUILDIR)"
	rm -rf "$(VTEST_DESTDIR)"

.PHONY: clean build
