#!/usr/bin/env bash

set -euo pipefail

SRC_REPO=$1
SRC_BRANCH=$2
OUT_DIR=$3

PARENT_DIR=$(dirname "$OUT_DIR")
[ -d "$PARENT_DIR" ] || mkdir -pv "$(dirname "$PARENT_DIR")"

apt -qq update && apt -qq -y --no-install-recommends install git

git clone "$SRC_REPO" "$OUT_DIR"
git -C "$OUT_DIR" checkout "$SRC_BRANCH"
