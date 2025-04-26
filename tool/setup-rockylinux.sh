#!/usr/bin/env bash

set -euo pipefail

dnf -y update
dnf -y install \
        bzip2-devel \
        cmake \
        jemalloc \
        jemalloc-devel \
        pcre2 \
        pcre2-devel

cc --version
