#!/usr/bin/env bash

set -euo pipefail

SRC_TARBALL=$1
OUT_DIR=$2

[ -d "$OUT_DIR" ] || mkdir -pv "$OUT_DIR"
pushd "$OUT_DIR"

echo "Ensuring dependencies"
apt -qq update && apt -qq -y --no-install-recommends install \
  ca-certificates \
  curl \
  tar

echo "Cloning QuicTLS from $SRC_TARBALL in $OUT_DIR..."
curl -sSL -o quictls.tar.gz "$SRC_TARBALL"
tar --strip-components=1 -xf quictls.tar.gz
rm -v quictls.tar.gz
