HAPROXY_VERSION = 2.6
HAPROXY_REPOSRC = http://git.haproxy.org/git/haproxy-$(HAPROXY_VERSION).git

HAPROXY_BUILDIR = src
HAPROXY_DESTDIR = dist
HAPROXY_DESTDIR_ABS = $(shell realpath $(HAPROXY_DESTDIR))
HAPROXY_ARCHIVE = haproxy-$(HAPROXY_VERSION)-dist.tar.gz

DEP_ROOT_LUA = ../deps/lua
DEP_ROOT_PCRE2 = ../deps/pcre2
DEP_ROOT_QUICTLS = ../deps/quictls

HAPROXY_MAKE_ARGS := DEBUG="-DDEBUG_STRICT -DDEBUG_MEMORY_POOLS" \
                     LDFLAGS="-Wl,-rpath,/opt/quictls/lib" \
                     TARGET="linux-glibc" \
                     EXTRAVERSION="+mangadex" \
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

all: build $(HAPROXY_DESTDIR) $(HAPROXY_ARCHIVE)

$(HAPROXY_BUILDIR):
	git clone "$(HAPROXY_REPOSRC)" $(HAPROXY_BUILDIR)
	git -C "$(HAPROXY_BUILDIR)" checkout "master"

build: $(HAPROXY_BUILDIR)
	make -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(HAPROXY_MAKE_ARGS) opts
	make -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(HAPROXY_MAKE_ARGS)

$(HAPROXY_DESTDIR):
	@if ! [ -d "$(HAPROXY_DESTDIR)" ]; then mkdir -v "$(HAPROXY_DESTDIR)"; fi
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(HAPROXY_DESTDIR_ABS)" install

$(HAPROXY_ARCHIVE): $(HAPROXY_DESTDIR)
	tar -C "$(HAPROXY_DESTDIR)" -cjf "$(HAPROXY_ARCHIVE)" "usr"

clean:
	rm -rf "$(HAPROXY_BUILDIR)"
	rm -rf "$(HAPROXY_DESTDIR)"
	rm -fv "$(HAPROXY_ARCHIVE)"

.PHONY: clean build $(HAPROXY_DESTDIR)
