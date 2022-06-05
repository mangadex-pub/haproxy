#!/usr/bin/env bash

set -euo pipefail

SRC_DIR=$1
QUICTLS_PREFIX=$2
HAPROXY_PREFIX=$3

if ! [ -d "$QUICTLS_PREFIX/include" ]; then
  echo "No include dir in $QUICTLS_PREFIX"
fi
if ! [ -d "$QUICTLS_PREFIX/lib" ]; then
  echo "No lib dir in $QUICTLS_PREFIX"
fi

apt -qq update && apt -qq -y --no-install-recommends install \
  liblua5.3-dev \
  libpcre2-dev \
  libsystemd-dev

pushd "$SRC_DIR"

# HAProxy build flags
make -j "$(nproc)" \
  DEBUG="-DDEBUG_STRICT -DDEBUG_MEMORY_POOLS" \
  LDFLAGS="-Wl,-rpath,${QUICTLS_PREFIX}/lib" \
  SSL_INC="${QUICTLS_PREFIX}/include" \
  SSL_LIB="${QUICTLS_PREFIX}/lib" \
  TARGET="linux-glibc" \
  EXTRAVERSION="+mangadex" \
  VERDATE="$(date -u -I'minutes')" \
  USE_DL=1 \
  USE_GETADDRINFO=1 \
  USE_LINUX_TPROXY=1 \
  USE_LUA=1 \
  USE_OPENSSL=1 \
  USE_PCRE2=1 \
  USE_PCRE2_JIT=1 \
  USE_PROMEX=1 \
  USE_QUIC=1 \
  USE_SLZ=1 \
  USE_TFO=1 \
  USE_SYSTEMD=1

[ "${HAPROXY_MAKE_INSTALL:-'false'}" == "true" ] && make -j"$(nproc)" DESTDIR="${HAPROXY_PREFIX}" install
