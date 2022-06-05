#!/usr/bin/env bash

set -euo pipefail

SRC_DIR=$1
OUT_DIR=$2

[ -d "$OUT_DIR" ] || mkdir -pv "$OUT_DIR"
pushd "$SRC_DIR"

echo "Ensuring dependencies"
apt -qq update && apt -qq -y --no-install-recommends install \
  build-essential

./Configure --libdir=lib -static --prefix="$OUT_DIR" --openssldir="$OUT_DIR"
make -j "$(nproc)"

[ "${QUICTLS_MAKE_INSTALL:-'false'}" == "true" ] && make -j"$(nproc)" install
