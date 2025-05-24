#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -q update
apt-get -qq -y --no-install-recommends install apt-utils apt-transport-https ca-certificates
apt-get -q update
apt-get -qq -y --no-install-recommends install \
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
      pkg-config \
      ruby \
      rubygems \
      tar \
      zip unzip \
      zlib1g-dev

cc --version
