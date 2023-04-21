HAPROXY_GITREPO = https://git.haproxy.org/?p=haproxy-2.7.git
HAPROXY_VERSION = 2.7-stable
HAPROXY_GITREF = 4dadaaafb20106619510fd3fc6f2819f47777729
HAPROXY_SHORTSHA = $(shell echo "$(HAPROXY_GITREF)" | grep -Eo '^.{7}' || echo "$(HAPROXY_GITREF)")
HAPROXY_VERSION_MINOR = $(shell echo "$(HAPROXY_VERSION)" | cut -d'.' -f1-2)

HAPROXY_SOURCES = $(HAPROXY_GITREPO);a=snapshot;h=$(HAPROXY_GITREF);sf=tgz
HAPROXY_TARBALL = haproxy-$(HAPROXY_VERSION)-$(HAPROXY_SHORTSHA).tar.gz
HAPROXY_DEBORIG = haproxy_$(HAPROXY_VERSION)-$(HAPROXY_SHORTSHA).orig.tar.gz
HAPROXY_BUILDIR = src
HAPROXY_DESTDIR = dist
HAPROXY_DESTDIR_ABS = $(shell realpath $(HAPROXY_DESTDIR))
HAPROXY_ARCHIVE = haproxy-dist.tar.gz

DEP_DIST_ROOT_LUA = $(shell realpath ../deps/lua/dist)
DEP_DIST_ROOT_PCRE2 = $(shell realpath ../deps/pcre2/dist)
DEP_DIST_ROOT_QUICTLS = $(shell realpath ../deps/quictls/dist)
DEP_DIST_ROOT_VTEST = $(shell realpath ../deps/vtest/dist)

BUILD_VERSION_REPOSHA = $(shell git rev-parse --short HEAD)

BUILD_PATCHES_DIR = $(shell realpath patches-stable)
BUILD_PATCHES_FILES = $(shell ls -1 $(BUILD_PATCHES_DIR))
DEBIAN_PATCHES_DIR = "$(HAPROXY_BUILDIR)/debian/patches"

DEBUG_CFLAGS = -ggdb3 -gdwarf-4

MAKEARGS = DEBUG="-DDEBUG_MEMORY_POOLS -DDEBUG_STRICT" \
           DEBUG_CFLAGS="$(DEBUG_CFLAGS)"\
           DEFINE="-DMAX_SESS_STKCTR=5" \
           IGNOREGIT=true \
           ADDLIB="-Wl,-rpath,/opt/quictls/lib" \
           TARGET="linux-glibc" \
           EXTRAVERSION="+mangadex-$(BUILD_VERSION_REPOSHA)" \
           VERDATE="$(shell date -u -I'minutes')" \
           USE_LIBCRYPT=1 \
           USE_LUA=1 \
           LUA_INC="$(DEP_DIST_ROOT_LUA)/include" \
           LUA_LIB="$(DEP_DIST_ROOT_LUA)/lib" \
           LUA_LIB_NAME="lua" \
           USE_OPENSSL=1 \
           SSL_INC="$(DEP_DIST_ROOT_QUICTLS)/opt/quictls/include" \
           SSL_LIB="$(DEP_DIST_ROOT_QUICTLS)/opt/quictls/lib" \
           USE_PCRE2=1 \
           USE_PROMEX=1 \
           USE_QUIC=1 \
           USE_SLZ=1 \
           USE_TFO=1

HAPROXY_LIBASAN = false
ifeq ($(HAPROXY_LIBASAN),true)
	DEBUG_CFLAGS += -static-libsan
	DEBUG_CFLAGS += -fsanitize=address
	DEBUG_CFLAGS += -fno-omit-frame-pointer
	MAKEARGS += LDFLAGS="-fsanitize=address"
	MAKEARGS += USE_OBSOLETE_LINKER="1"
	# set -O1 rather than the default -O2 since LibAsan builds are debug-purpose anyway
	MAKEARGS += CPU_CFLAGS="-O1"
endif

MAKEARGS_LINUX = $(MAKEARGS) \
				 PCRE2_LIB="$(DEP_DIST_ROOT_PCRE2)/lib64" \
				 PCRE2_INC="$(DEP_DIST_ROOT_PCRE2)/include" \
                 PCRE2_CONFIG="$(DEP_DIST_ROOT_PCRE2)/bin/pcre2-config" \
           		 USE_PCRE2_JIT=1 \
           		 USE_STATIC_PCRE2=1 \
				 USE_NS=1 \
				 USE_SYSTEMD=1 \
				 TARGET=linux-glibc

MAKEARGS_DARWIN = $(MAKEARGS) \
				  CC=$(shell brew --prefix llvm)/bin/clang \
				  LD=$(shell brew --prefix llvm)/bin/clang \
				  TARGET=osx

all: dist-bin

dist-bin: build $(HAPROXY_DESTDIR) $(HAPROXY_ARCHIVE)
dist-deb: build-deb

$(HAPROXY_TARBALL):
	curl -sfS -o "$(HAPROXY_TARBALL)" "$(HAPROXY_SOURCES)"

$(HAPROXY_BUILDIR): $(HAPROXY_TARBALL)
	@if ! [ -d "$(HAPROXY_BUILDIR)" ]; then mkdir -v "$(HAPROXY_BUILDIR)"; fi
	tar -C "$(HAPROXY_BUILDIR)" --strip-components=1 -xf "$(HAPROXY_TARBALL)"

patches: $(HAPROXY_BUILDIR)
	@cd "$(HAPROXY_BUILDIR)" && for patch in $(BUILD_PATCHES_FILES); do patch -p1 --forward < "$(BUILD_PATCHES_DIR)/$${patch}" || true; done

build: $(HAPROXY_BUILDIR) patches
	$(info Enabling address sanitizer: $(HAPROXY_LIBASAN))
	$(MAKE) build_$(shell uname -s)
	if [ -d "$(HAPROXY_BUILDIR)/dev/haring" ]; then $(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" dev/haring/haring; fi

.PHONY: build_Linux
build_Linux:
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_LINUX) opts
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_LINUX)

.PHONY: build_Darwin
build_Darwin:
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_DARWIN) opts
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_DARWIN)

test: $(HAPROXY_BUILDIR)
	if ! VTEST_PROGRAM="$(DEP_DIST_ROOT_VTEST)/vtest" $(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" REGTESTS_TYPES=default,bug,devel reg-tests; then ls -alh; echo "Stalling due to failure"; sleep 3000; fi

.PHONY: $(HAPROXY_DESTDIR)
$(HAPROXY_DESTDIR):
	@if [ -d "$(HAPROXY_DESTDIR)" ]; then rm -rf $(HAPROXY_DESTDIR); fi
	@mkdir -pv "$(HAPROXY_DESTDIR)"
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(HAPROXY_DESTDIR_ABS)" install
	if [ -f "$(HAPROXY_BUILDIR)/dev/haring/haring" ]; then install -m 0755 -D "$(HAPROXY_BUILDIR)/dev/haring/haring" "$(HAPROXY_DESTDIR_ABS)/usr/local/sbin/haring"; fi
	if ! $(HAPROXY_DESTDIR_ABS)/usr/local/sbin/haproxy -vv; then ls -alh; echo "Stalling due to crash"; sleep 3000; fi
	ldd $(HAPROXY_DESTDIR_ABS)/usr/local/sbin/haproxy

$(HAPROXY_ARCHIVE): $(HAPROXY_DESTDIR)
	tar -C "$(HAPROXY_DESTDIR)" -cjf "$(HAPROXY_ARCHIVE)" "usr"

$(HAPROXY_DEBORIG): $(HAPROXY_TARBALL)
	cp -fv "$(HAPROXY_TARBALL)" "$(HAPROXY_DEBORIG)"

prepare-deb: $(HAPROXY_DEBORIG) $(HAPROXY_BUILDIR)
	cp -rf debian $(HAPROXY_BUILDIR)/
	@for patch in $(BUILD_PATCHES_FILES); do cp -v "$(BUILD_PATCHES_DIR)/$${patch}" "$(DEBIAN_PATCHES_DIR)/$${patch}"; done
	@for patch in $(BUILD_PATCHES_FILES); do echo "$${patch}" >> "$(DEBIAN_PATCHES_DIR)/series"; done
	export BUILD_DATE="$(shell date -u +'%a, %e %b %Y %H:%m:%S %z')" && \
		export BUILD_VERSION="$(HAPROXY_VERSION)-$(HAPROXY_SHORTSHA)-1~mangadex+$(BUILD_VERSION_REPOSHA)" && \
		export BUILD_MESSAGE="$(shell echo "$${BUILD_MESSAGE:-"No build message"}" | head -n1)" && \
		envsubst < changelog.debian | tee "$(HAPROXY_BUILDIR)/debian/changelog" && \
		cat debian/changelog >> "$(HAPROXY_BUILDIR)/debian/changelog"

build-deb: prepare-deb
	export HAPROXY_LIBASAN="$(HAPROXY_LIBASAN)" && \
		cd $(HAPROXY_BUILDIR) && \
		debuild -us -uc --lintian-opts --no-lintian
	rm -fv $(HAPROXY_TARBALL)
	rm -rf $(HAPROXY_BUILDIR)

clean:
	rm -fv "$(HAPROXY_TARBALL)"
	rm -rf "$(HAPROXY_DEBORIG)"
	rm -rf "$(HAPROXY_BUILDIR)"
	rm -rf "$(HAPROXY_DESTDIR)"
	rm -fv "$(HAPROXY_ARCHIVE)"
	rm -fv "haproxy_"*
	rm -fv "haproxy-dbgsym_"*

.PHONY: clean patches build test prepare-deb
