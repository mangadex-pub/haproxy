# source inputs
HAPROXY_GITREPO ?= https://git.haproxy.org/?p=haproxy-3.1.git
HAPROXY_VERSION ?= 3.1-stable
HAPROXY_GITREF  ?= v3.1.3

# build flavour options
BUILD_PATCHES_DIR    ?= $(shell realpath patches-stable)
HAPROXY_LIBASAN      ?= false
HAPROXY_LIBUBSAN     ?= false
HAPROXY_OPTIMIZATION ?= -O2

# resolved configuration
HAPROXY_SHORTSHA = $(shell echo "$(HAPROXY_GITREF)" | grep -Eo '^.{7}' || echo "$(HAPROXY_GITREF)")
HAPROXY_VERSION_MINOR = $(shell echo "$(HAPROXY_VERSION)" | cut -d'.' -f1-2)
HAPROXY_SOURCES = $(HAPROXY_GITREPO);a=snapshot;h=$(HAPROXY_GITREF);sf=tgz
HAPROXY_TARBALL = haproxy-$(HAPROXY_VERSION)-$(HAPROXY_SHORTSHA).src.tar.gz
HAPROXY_DEBORIG = haproxy_$(HAPROXY_VERSION)-$(HAPROXY_SHORTSHA).orig.tar.gz
HAPROXY_BUILDIR = src
HAPROXY_DESTDIR = dist
HAPROXY_DESTDIR_ABS = $(shell realpath $(HAPROXY_DESTDIR))
HAPROXY_ARCHIVE = haproxy-dist.tar.gz

DEP_DIST_ROOT_LUA = $(shell realpath ../deps/lua/dist)
DEP_DIST_ROOT_PCRE2 = $(shell realpath ../deps/pcre2/dist)
DEP_DIST_ROOT_AWSLC = $(shell realpath ../deps/awslc/dist)
DEP_DIST_ROOT_QUICTLS = $(shell realpath ../deps/quictls/dist)
DEP_DIST_ROOT_VTEST = $(shell realpath ../deps/vtest/dist)

BUILD_VERSION_REPOSHA = $(shell git rev-parse --short HEAD)

# distfile versioning
DIST_UPSTREAM_VERSION = $(shell echo "$(HAPROXY_VERSION)+$(HAPROXY_GITREF)" | tr -d "-")
DIST_RELEASE_VERSION = mangadex+$(BUILD_VERSION_REPOSHA)
DIST_FULL_VERSION = $(DIST_UPSTREAM_VERSION)~$(DIST_RELEASE_VERSION)

# re-deref ensures overrides using relative paths get expanded
BUILD_PATCHES_DIR_ABS = $(shell realpath $(BUILD_PATCHES_DIR))
BUILD_PATCHES_FILES = $(shell ls -1 $(BUILD_PATCHES_DIR_ABS))
DEBIAN_PATCHES_DIR = "$(HAPROXY_BUILDIR)/debian/patches"

EXTRA_CFLAGS = -g -ggdb3 -gdwarf-4 -Wall -Wextra

OPT_CFLAGS = $(HAPROXY_OPTIMIZATION)

ifeq ($(HAPROXY_LIBUBSAN),true)
	# set -Og (-O1 and some extra debug compat features) rather than the default -O2, since UBsan builds are for debug
	OPT_CFLAGS = -Og
	EXTRA_CFLAGS += -fsanitize=undefined
	EXTRA_CFLAGS += -static-libsan
endif

ifeq ($(HAPROXY_LIBASAN),true)
	# set -Og (-O1 and some extra debug compat features) rather than the default -O2, since LibAsan builds are for debug
	OPT_CFLAGS = -Og
	EXTRA_CFLAGS += -fsanitize=address
	EXTRA_CFLAGS += -static-libsan
	EXTRA_CFLAGS += -fsanitize-address-use-after-scope
	EXTRA_CFLAGS += -fno-omit-frame-pointer
	MAKEARGS += USE_OBSOLETE_LINKER="1"
endif

MAKEARGS = CC=$(CC) \
			ERR=0 \
			DEBUG="-DDEBUG_STRICT -DDEBUG_MEMORY_POOLS -DDEBUG_DONT_SHARE_POOLS -DDEBUG_POOL_INTEGRITY" \
			OPT_CFLAGS="$(OPT_CFLAGS)" \
			DEFINE="-DMAX_SESS_STKCTR=5" \
			IGNOREGIT=true \
			ARCH_FLAGS="$(EXTRA_CFLAGS)" \
			TARGET="linux-glibc" \
			EXTRAVERSION="+mangadex-$(BUILD_VERSION_REPOSHA)" \
			VERDATE="$(shell date -u -I'minutes')" \
			USE_LIBCRYPT=1 \
			USE_LUA=1 \
			LUA_INC="$(DEP_DIST_ROOT_LUA)/include" \
			LUA_LIB="$(DEP_DIST_ROOT_LUA)/lib" \
			LUA_LIB_NAME="lua" \
			USE_OPENSSL=1 \
			USE_PROMEX=1 \
			USE_QUIC=1 \
			USE_SLZ=1 \
			USE_TFO=1

HAPROXY_SSL_LIB = awslc
ifeq ($(HAPROXY_SSL_LIB),quictls)
ADDLIB   += -Wl,-rpath,/opt/quictls/lib
MAKEARGS += SSL_INC="$(DEP_DIST_ROOT_QUICTLS)/opt/quictls/include" \
				SSL_LIB="$(DEP_DIST_ROOT_QUICTLS)/opt/quictls/lib"
DEP_DIST_SSL_CURRENT=$(DEP_DIST_ROOT_QUICTLS)
endif
ifeq ($(HAPROXY_SSL_LIB),awslc)
ADDLIB   += -Wl,-rpath,/opt/awslc/lib
# here the SSL_LIB path *must* match the AWS-LC side distpath
# on some systems, CMAKE_INSTALL_LIBDIR=lib64 because we keep
# on complicating our life for the 0.00003% of asses still on
# 32 bits *eyeroll*; so it's explicitly set there
MAKEARGS += USE_OPENSSL_AWSLC=1 \
				SSL_INC="$(DEP_DIST_ROOT_AWSLC)/opt/awslc/include" \
				SSL_LIB="$(DEP_DIST_ROOT_AWSLC)/opt/awslc/lib"
DEP_DIST_SSL_CURRENT=$(DEP_DIST_ROOT_AWSLC)
endif

ADDLIB += -ljemalloc
MAKEARGS += ADDLIB="$(ADDLIB)"

MAKEARGS_LINUX = $(MAKEARGS) \
					PCRE2_LIB="$(DEP_DIST_ROOT_PCRE2)/lib64" \
					PCRE2_INC="$(DEP_DIST_ROOT_PCRE2)/include" \
					PCRE2_CONFIG="$(DEP_DIST_ROOT_PCRE2)/bin/pcre2-config" \
					USE_PCRE2_JIT=1 \
					USE_STATIC_PCRE2=1 \
					USE_NS=1 \
					TARGET=linux-glibc

MAKEARGS_DARWIN = $(MAKEARGS) \
					CC=$(shell brew --prefix llvm)/bin/clang \
					LD=$(shell brew --prefix llvm)/bin/clang \
					USE_PCRE2=1 \
					TARGET=osx

all: build

$(HAPROXY_TARBALL):
	curl -sfS -o "$(HAPROXY_TARBALL)" "$(HAPROXY_SOURCES)"

$(HAPROXY_BUILDIR): $(HAPROXY_TARBALL)
	@if ! [ -d "$(HAPROXY_BUILDIR)" ]; then mkdir -v "$(HAPROXY_BUILDIR)"; fi
	tar -C "$(HAPROXY_BUILDIR)" --strip-components=1 -xf "$(HAPROXY_TARBALL)"

patches: $(HAPROXY_BUILDIR)
	@echo "Applying patches from $(BUILD_PATCHES_DIR_ABS)..."
	@cd "$(HAPROXY_BUILDIR)" && for patch in $(BUILD_PATCHES_FILES); do patch -p1 --forward < "$(BUILD_PATCHES_DIR_ABS)/$${patch}" || true; done

build: $(HAPROXY_BUILDIR) patches
	$(info Enabling address sanitizer: $(HAPROXY_LIBASAN))
	$(MAKE) build_$(shell uname -s)
	if [ -d "$(HAPROXY_BUILDIR)/dev/haring" ]; then $(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" dev/haring/haring; fi
	if [ -d "$(HAPROXY_BUILDIR)/admin/systemd" ]; then $(MAKE) -C "$(HAPROXY_BUILDIR)/admin/systemd" -j "$(shell nproc)"; fi

.PHONY: build_Linux
build_Linux:
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_LINUX) opts
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_LINUX)

.PHONY: build_Darwin
build_Darwin:
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_DARWIN) opts
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" $(MAKEARGS_DARWIN)

test: $(HAPROXY_BUILDIR) patches
	#@if [ "$(shell ulimit -n)" = "1073741816" ]; then \
	#    echo "Current environment likely has broken file descriptor limit (1073741816). Use ulimit -n 65536 before running regtests."; \
	#    exit 1; \
	#fi
	@mkdir -pv /tmp/vtest
	if ! TMPDIR="/tmp/vtest" VTEST_PROGRAM="$(DEP_DIST_ROOT_VTEST)/vtest" $(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)"  reg-tests REGTESTS_TYPES=default,bug,devel; then $(MAKE) regfail-logs; fi

.PHONY: regfail-logs
regfail-logs:
	@for folder in /tmp/vtest/haregtests-*/vtc.*; do \
		echo "* $${folder}"; \
		cat $$folder/INFO; \
		cat $$folder/LOG; \
		echo ""; \
	done

.PHONY: $(HAPROXY_DESTDIR)
$(HAPROXY_DESTDIR):
	@if [ -d "$(HAPROXY_DESTDIR)" ]; then rm -rf $(HAPROXY_DESTDIR); fi
	@mkdir -pv "$(HAPROXY_DESTDIR)"
	$(MAKE) -C "$(HAPROXY_BUILDIR)" -j "$(shell nproc)" DESTDIR="$(HAPROXY_DESTDIR_ABS)" install

	@# install haring and systemd integration
	if [ -f "$(HAPROXY_BUILDIR)/dev/haring/haring" ]; then install -m 0755 -D "$(HAPROXY_BUILDIR)/dev/haring/haring" "$(HAPROXY_DESTDIR_ABS)/usr/local/sbin/haring"; fi
	if [ -f "$(HAPROXY_BUILDIR)/admin/systemd/haproxy.service" ]; then install -m 0644 -D "$(HAPROXY_BUILDIR)/admin/systemd/haproxy.service" "$(HAPROXY_DESTDIR_ABS)/usr/lib/systemd/system/haproxy.service"; fi

	install -m 0644 -D "haproxy.default" "$(HAPROXY_DESTDIR_ABS)/etc/default/haproxy"
	install -m 0644 -D "haproxy.cfg" "$(HAPROXY_DESTDIR_ABS)/etc/haproxy/haproxy.cfg"
	install -m 0644 -D "haproxy.tmpfile" "$(HAPROXY_DESTDIR_ABS)/usr/lib/tmpfiles.d/haproxy.conf"

	if ! $(HAPROXY_DESTDIR_ABS)/usr/local/sbin/haproxy -vv; then ls -alh; fi
	ldd $(HAPROXY_DESTDIR_ABS)/usr/local/sbin/haproxy

$(HAPROXY_ARCHIVE): $(HAPROXY_DESTDIR)
	tar -C "$(HAPROXY_DESTDIR)" -cjf "$(HAPROXY_ARCHIVE)" "usr"

$(HAPROXY_DEBORIG): $(HAPROXY_TARBALL)
	cp -fv "$(HAPROXY_TARBALL)" "$(HAPROXY_DEBORIG)"

prepare-dist: build $(HAPROXY_DESTDIR)
	@if ! command -v fpm >/dev/null; then echo "fpm not found, install it 'gem install fpm'"; exit 1; else fpm --version; fi
	cp -rf $(DEP_DIST_SSL_CURRENT)/* $(HAPROXY_DESTDIR)/
	@mkdir -pv $(HAPROXY_DESTDIR)/etc/haproxy
	@mkdir -pv $(HAPROXY_DESTDIR)/var/lib/haproxy

dist-deb: prepare-dist
	@if [ -f "haproxy-$(DIST_FULL_VERSION).deb" ]; then rm -v "haproxy-$(DIST_FULL_VERSION).deb"; fi
	fpm --input-type dir \
		--output-type deb \
		--package "haproxy-$(DIST_FULL_VERSION).deb" \
		--name "haproxy" \
		--architecture "native" \
		--license "mit+gpl2+lgpl" \
		--version "$(DIST_FULL_VERSION)" \
		--depends "libatomic1" \
		--depends "libjemalloc2" \
		--depends "socat" \
		--depends "zlib1g" \
		--description "HAProxy mainline build with QUIC (via $(HAPROXY_SSL_LIB))" \
		--url "https://gitlab.com/mangadex-pub/haproxy" \
		--maintainer "MangaDex <opensource@mangadex.org>" \
		--config-files "/etc" \
		--before-install "toil/deb-adduser.sh" \
		--after-remove "toil/deb-deluser.sh" \
		"$(HAPROXY_DESTDIR)/etc/=/etc" \
		"$(HAPROXY_DESTDIR)/opt/=/opt" \
		"$(HAPROXY_DESTDIR)/usr/=/usr"

	dpkg -c "haproxy-$(DIST_FULL_VERSION).deb"

dist-rpm: prepare-dist
	@if [ -f "haproxy-$(DIST_FULL_VERSION).rpm" ]; then rm -v "haproxy-$(DIST_FULL_VERSION).rpm"; fi
	fpm --input-type dir \
		--output-type rpm \
		--package "haproxy-$(DIST_FULL_VERSION).rpm" \
		--name "haproxy" \
		--architecture "native" \
		--license "mit+gpl2+lgpl" \
		--version "$(DIST_FULL_VERSION)" \
		--depends "jemalloc" \
		--depends "socat" \
		--description "HAProxy mainline build with QUIC (via $(HAPROXY_SSL_LIB))" \
		--url "https://gitlab.com/mangadex-pub/haproxy" \
		--maintainer "MangaDex <opensource@mangadex.org>" \
		--config-files "/etc" \
		--before-install "toil/rpm-adduser.sh" \
		--after-remove "toil/rpm-deluser.sh" \
		"$(HAPROXY_DESTDIR)/etc/=/etc" \
		"$(HAPROXY_DESTDIR)/opt/=/opt" \
		"$(HAPROXY_DESTDIR)/usr/=/usr"

	rpm -qpl "haproxy-$(DIST_FULL_VERSION).rpm"

clean:
	rm -fv "$(HAPROXY_ARCHIVE)"
	rm -rf "$(HAPROXY_BUILDIR)"
	rm -rf "$(HAPROXY_DEBORIG)"
	rm -rf "$(HAPROXY_DESTDIR)"
	# rm -fv "haproxy"*.deb
	# rm -fv "haproxy"*.rpm

.PHONY: clean patches build test
