#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt -qq update
apt -qq -y --no-install-recommends install apt-utils apt-transport-https ca-certificates
apt -qq update
apt -qq -y --no-install-recommends install \
      build-essential \
      bzip2 \
      ca-certificates \
      cmake \
      curl \
      debhelper \
      debian-archive-keyring \
      devscripts \
      git \
      gnupg2 \
      libjemalloc-dev \
      libpcre2-dev \
      libreadline-dev \
      libsystemd-dev \
      pkg-config \
      tar \
      zip unzip \
      zlib1g-dev
