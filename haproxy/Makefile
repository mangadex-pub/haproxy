HAPROXY_REPO_SRC = http://git.haproxy.org/git/haproxy-2.6.git
HAPROXY_DESTDIR = dist
HAPROXY_DESTDIR_ABS = $(shell realpath $(HAPROXY_DESTDIR))

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
                     USE_PCRE2=1 \
                     USE_PCRE2_JIT=1 \
                     USE_STATIC_PCRE2=1 \
                     PCRE2_INC="../$(DEP_ROOT_PCRE2)/dist/include" \
                     PCRE2_LIB="../$(DEP_ROOT_PCRE2)/dist/lib" \
                     USE_PROMEX=1 \
                     USE_QUIC=1 \
                     USE_SLZ=1 \
                     USE_TFO=1 \
                     USE_SYSTEMD=1

all: build $(HAPROXY_DESTDIR)

src:
	git clone "$(HAPROXY_REPO_SRC)" src
	git -C "src" checkout "master"

build: src
	make -C "src" -j "$(shell nproc)" $(HAPROXY_MAKE_ARGS) opts
	make -C "src" -j "$(shell nproc)" $(HAPROXY_MAKE_ARGS)

$(HAPROXY_DESTDIR):
	if ! [ -d "$(HAPROXY_DESTDIR)" ]; then mkdir -v "$(HAPROXY_DESTDIR)"; fi
	$(MAKE) -C "src" -j "$(shell nproc)" DESTDIR="$(HAPROXY_DESTDIR_ABS)" install

clean:
	git -C "src" clean -fdx

.PHONY: clean build $(HAPROXY_DESTDIR)
