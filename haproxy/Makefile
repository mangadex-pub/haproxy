HAPROXY_VERSION = 2.6.0
HAPROXY_VERSION_TAG = v$(HAPROXY_VERSION)
HAPROXY_VERSION_MINOR = $(shell echo "$(HAPROXY_VERSION)" | cut -d'.' -f1-2)

HAPROXY_SOURCES = https://git.haproxy.org/?p=haproxy-$(HAPROXY_VERSION_MINOR).git;a=snapshot;h=$(HAPROXY_VERSION_TAG);sf=tgz
HAPROXY_TARBALL = haproxy-$(HAPROXY_VERSION).tar.gz
HAPROXY_BUILDIR = src
HAPROXY_DESTDIR = dist
HAPROXY_DESTDIR_ABS = $(shell realpath $(HAPROXY_DESTDIR))
HAPROXY_ARCHIVE = haproxy-dist.tar.gz

DEP_ROOT_LUA = ../deps/lua
DEP_ROOT_PCRE2 = ../deps/pcre2
DEP_ROOT_QUICTLS = ../deps/quictls

BUILD_VERSION_REPOSHA = $(shell git rev-parse --short HEAD)

HAPROXY_MAKE_ARGS := DEBUG="-DDEBUG_STRICT -DDEBUG_MEMORY_POOLS" \
					 DEFINE="-DMAX_SESS_STKCTR=5" \
                     LDFLAGS="-Wl,-rpath,/opt/quictls/lib" \
                     TARGET="linux-glibc" \
                     EXTRAVERSION="+mangadex/$(BUILD_VERSION_REPOSHA)" \
                     VERDATE="$$(date -u -I'minutes')" \
                     USE_DL=1 \
                     USE_GETADDRINFO=1 \
                     USE_LINUX_TPROXY=1 \
                     USE_LUA=1 \
                     LUA_INC="../$(DEP_ROOT_LUA)/dist/include" \
                     LUA_LIB="../$(DEP_ROOT_LUA)/dist/lib" \
                     LUA_LIB_NAME="lua" \
                     USE_OPENSSL=1 \
                     SSL_INC="../$(DEP_ROOT_QUICTLS)/dist/opt/quictls/include" \
                     SSL_LIB="../$(DEP_ROOT_QUICTLS)/dist/opt/quictls/lib" \
                     ADDINC="-lcrypt" \
                     USE_PCRE2=1 \
                     USE_PCRE2_JIT=1 \
                     USE_STATIC_PCRE2=1 \
                     PCRE2_INC="../$(DEP_ROOT_PCRE2)/dist/include" \
                     PCRE2_LIB="../$(DEP_ROOT_PCRE2)/dist/lib64" \
                     PCRE2_CONFIG="../$(DEP_ROOT_PCRE2)/dist/bin/pcre2-config" \
                     USE_PROMEX=1 \
                     USE_QUIC=1 \
                     USE_SLZ=1 \
                     USE_TFO=1 \
                     USE_SYSTEMD=1

all: dist-bin

dist-bin: build $(HAPROXY_DESTDIR) $(HAPROXY_ARCHIVE)

$(HAPROXY_TARBALL):
	curl -sfS -o "$(HAPROXY_TARBALL)" "$(HAPROXY_SOURCES)"

$(HAPROXY_BUILDIR): $(HAPROXY_TARBALL)
	@if ! [ -d "$(HAPROXY_BUILDIR)" ]; then mkdir -v "$(HAPROXY_BUILDIR)"; fi
	tar -C "$(HAPROXY_BUILDIR)" --strip-components=1 -xf "$(HAPROXY_TARBALL)"

build: $(HAPROXY_BUILDIR)
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(HAPROXY_MAKE_ARGS) opts
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(HAPROXY_MAKE_ARGS)

$(HAPROXY_DESTDIR):
	@if ! [ -d "$(HAPROXY_DESTDIR)" ]; then mkdir -v "$(HAPROXY_DESTDIR)"; fi
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(HAPROXY_DESTDIR_ABS)" install

$(HAPROXY_ARCHIVE): $(HAPROXY_DESTDIR)
	tar -C "$(HAPROXY_DESTDIR)" -cjf "$(HAPROXY_ARCHIVE)" "usr"

clean:
	rm -fv "$(HAPROXY_TARBALL)"
	rm -rf "$(HAPROXY_BUILDIR)"
	rm -rf "$(HAPROXY_DESTDIR)"
	rm -fv "$(HAPROXY_ARCHIVE)"

.PHONY: clean build
