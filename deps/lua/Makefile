LUA_VERSION = 5.3.6
LUA_SOURCES = https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz
LUA_TARBALL = lua-$(LUA_VERSION).tar.gz
LUA_DESTDIR = dist
LUA_DESTDIR_ABS = $(shell realpath $(LUA_DESTDIR))

all: build $(LUA_DESTDIR)

src:
	if ! [ -d "src" ]; then mkdir -v "src"; fi

src/lua-$(LUA_VERSION).tar.gz: src
	curl -sSL -o "$(LUA_TARBALL)" "$(LUA_SOURCES)"

build: src/lua-$(LUA_VERSION).tar.gz
	tar -C src --strip-components=1 -xf "$(LUA_TARBALL)"
	$(MAKE) -C src -j$(shell nproc) linux

$(LUA_DESTDIR): build
	if ! [ -d "$(LUA_DESTDIR)" ]; then mkdir -v "$(LUA_DESTDIR)"; fi
	$(MAKE) -C src -j$(shell nproc) install	INSTALL_TOP="$(LUA_DESTDIR_ABS)"

clean:
	rm -rf "src"
	rm -rf "$(LUA_DESTDIR)"

.PHONY: clean build
