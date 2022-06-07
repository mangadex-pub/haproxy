HAPROXY_VERSION = 2.6.0
HAPROXY_VERSION_MINOR = $(shell echo "$(HAPROXY_VERSION)" | cut -d'.' -f1-2)

HAPROXY_SOURCES = https://www.haproxy.org/download/$(HAPROXY_VERSION_MINOR)/src/haproxy-$(HAPROXY_VERSION).tar.gz
HAPROXY_TARBALL = haproxy-$(HAPROXY_VERSION).tar.gz
HAPROXY_DEBORIG = haproxy_$(HAPROXY_VERSION).orig.tar.gz
HAPROXY_BUILDIR = src
HAPROXY_DESTDIR = dist
HAPROXY_DESTDIR_ABS = $(shell realpath $(HAPROXY_DESTDIR))
HAPROXY_ARCHIVE = haproxy-dist.tar.gz

DEP_DIST_ROOT_LUA = $(shell realpath ../deps/lua/dist)
DEP_DIST_ROOT_PCRE2 = $(shell realpath ../deps/pcre2/dist)
DEP_DIST_ROOT_QUICTLS = $(shell realpath ../deps/quictls/dist)

BUILD_VERSION_REPOSHA = $(shell git rev-parse --short HEAD)

MAKEARGS = DEBUG="-DDEBUG_STRICT -DDEBUG_MEMORY_POOLS" \
           DEFINE="-DMAX_SESS_STKCTR=5" \
           IGNOREGIT=true \
           LDFLAGS="-Wl,-rpath,/opt/quictls/lib" \
           TARGET="linux-glibc" \
           EXTRAVERSION="+mangadex-$(BUILD_VERSION_REPOSHA)" \
           VERDATE="$(shell date -u -I'minutes')" \
           USE_DL=1 \
           USE_GETADDRINFO=1 \
           USE_LINUX_TPROXY=1 \
           USE_LUA=1 \
           LUA_INC="$(DEP_DIST_ROOT_LUA)/include" \
           LUA_LIB="$(DEP_DIST_ROOT_LUA)/lib" \
           LUA_LIB_NAME="lua" \
           USE_OPENSSL=1 \
           SSL_INC="$(DEP_DIST_ROOT_QUICTLS)/opt/quictls/include" \
           SSL_LIB="$(DEP_DIST_ROOT_QUICTLS)/opt/quictls/lib" \
           ADDINC="-lcrypt" \
           USE_PCRE2=1 \
           USE_PCRE2_JIT=1 \
           USE_STATIC_PCRE2=1 \
           PCRE2_INC="$(DEP_DIST_ROOT_PCRE2)/include" \
           PCRE2_LIB="$(DEP_DIST_ROOT_PCRE2)/lib64" \
           PCRE2_CONFIG="$(DEP_DIST_ROOT_PCRE2)/bin/pcre2-config" \
           USE_PROMEX=1 \
           USE_QUIC=1 \
           USE_SLZ=1 \
           USE_TFO=1 \
           USE_SYSTEMD=1

all: dist-bin

dist-bin: build $(HAPROXY_DESTDIR) $(HAPROXY_ARCHIVE)
dist-deb: build-deb

$(HAPROXY_TARBALL):
	curl -sfS -o "$(HAPROXY_TARBALL)" "$(HAPROXY_SOURCES)"

$(HAPROXY_BUILDIR): $(HAPROXY_TARBALL)
	@if ! [ -d "$(HAPROXY_BUILDIR)" ]; then mkdir -v "$(HAPROXY_BUILDIR)"; fi
	tar -C "$(HAPROXY_BUILDIR)" --strip-components=1 -xf "$(HAPROXY_TARBALL)"

build: $(HAPROXY_BUILDIR)
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS) opts
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS)

$(HAPROXY_DESTDIR):
	@if ! [ -d "$(HAPROXY_DESTDIR)" ]; then mkdir -v "$(HAPROXY_DESTDIR)"; fi
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(HAPROXY_DESTDIR_ABS)" install

$(HAPROXY_ARCHIVE): $(HAPROXY_DESTDIR)
	tar -C "$(HAPROXY_DESTDIR)" -cjf "$(HAPROXY_ARCHIVE)" "usr"

$(HAPROXY_DEBORIG): $(HAPROXY_TARBALL)
	cp -fv "$(HAPROXY_TARBALL)" "$(HAPROXY_DEBORIG)"

build-deb: $(HAPROXY_DEBORIG) $(HAPROXY_BUILDIR)
	cp -rf debian $(HAPROXY_BUILDIR)/
	cd $(HAPROXY_BUILDIR) && debuild -us -uc
	rm -fv $(HAPROXY_TARBALL)
	rm -rf $(HAPROXY_BUILDIR)

clean:
	rm -fv "$(HAPROXY_TARBALL)"
	rm -rf "$(HAPROXY_DEBORIG)"
	rm -rf "$(HAPROXY_BUILDIR)"
	rm -rf "$(HAPROXY_DESTDIR)"
	rm -fv "$(HAPROXY_ARCHIVE)"
	rm -fv "haproxy_$(HAPROXY_VERSION)"*
	rm -fv "haproxy-dbgsym_$(HAPROXY_VERSION)"*

.PHONY: clean build
