LUA_VERSION = 5.3.6
LUA_SOURCES = https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz
LUA_TARBALL = lua-$(LUA_VERSION).tar.gz
LUA_BUILDIR = src
LUA_DESTDIR = dist
LUA_DESTDIR_ABS = $(shell realpath $(LUA_DESTDIR))

all: $(LUA_BUILDIR) $(LUA_DESTDIR)

$(LUA_BUILDIR):
	@if ! [ -d "$(LUA_BUILDIR)" ]; then mkdir -v "$(LUA_BUILDIR)"; fi

$(LUA_BUILDIR)/lua-$(LUA_VERSION).tar.gz: $(LUA_BUILDIR)
	curl -sSL -o "$(LUA_TARBALL)" "$(LUA_SOURCES)"

build: $(LUA_BUILDIR)/lua-$(LUA_VERSION).tar.gz
	tar -C $(LUA_BUILDIR) --strip-components=1 -xf "$(LUA_TARBALL)"
	$(MAKE) -C $(LUA_BUILDIR) -j$(shell nproc) linux

$(LUA_DESTDIR): build
	if ! [ -d "$(LUA_DESTDIR)" ]; then mkdir -v "$(LUA_DESTDIR)"; fi
	$(MAKE) -C $(LUA_BUILDIR) -j$(shell nproc) install	INSTALL_TOP="$(LUA_DESTDIR_ABS)"

clean:
	rm -rf "$(LUA_BUILDIR)"
	rm -rf "$(LUA_DESTDIR)"
	rm -fv "$(LUA_TARBALL)"

.PHONY: clean build
