LUA_VERSION = 5.3.6
LUA_SOURCES = https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz
LUA_TARBALL = lua-$(LUA_VERSION).tar.gz
LUA_BUILDIR = src
LUA_DESTDIR = dist
LUA_DESTDIR_ABS = $(shell realpath $(LUA_DESTDIR))
LUA_ARCHIVE = lua-dist.tar.gz

all: build $(LUA_DESTDIR) $(LUA_ARCHIVE)

$(LUA_TARBALL):
	curl -fsSL -o "$(LUA_TARBALL)" "$(LUA_SOURCES)"

$(LUA_BUILDIR): $(LUA_TARBALL)
	@if ! [ -d "$(LUA_BUILDIR)" ]; then mkdir -v "$(LUA_BUILDIR)"; fi
	tar -C $(LUA_BUILDIR) --strip-components=1 -xf "$(LUA_TARBALL)"

build: $(LUA_BUILDIR)
	$(MAKE) -C $(LUA_BUILDIR) -j$(shell nproc) linux

$(LUA_DESTDIR): build
	if ! [ -d "$(LUA_DESTDIR)" ]; then mkdir -v "$(LUA_DESTDIR)"; fi
	$(MAKE) -C $(LUA_BUILDIR) -j$(shell nproc) install	INSTALL_TOP="$(LUA_DESTDIR_ABS)"

$(LUA_ARCHIVE): $(LUA_DESTDIR)
	tar -C "$(LUA_DESTDIR)" -cjf "$(LUA_ARCHIVE)" $$(ls -1 $(LUA_DESTDIR))

clean:
	rm -fv "$(LUA_TARBALL)"
	rm -rf "$(LUA_BUILDIR)"
	rm -rf "$(LUA_DESTDIR)"
	rm -fv "$(LUA_ARCHIVE)"

.PHONY: clean build
