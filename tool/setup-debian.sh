#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt -qq update
apt -qq -y --no-install-recommends install apt-utils apt-transport-https ca-certificates
sed -i -e 's/http\:/https\:/g' /etc/apt/sources.list
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
      libpcre2-dev \
      libreadline-dev \
      libsystemd-dev \
      pkg-config \
      tar \
      zlib1g-dev
