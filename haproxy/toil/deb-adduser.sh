#!/usr/bin/env bash

set -euo pipefail

adduser \
  --system \
  --disabled-password \
  --disabled-login \
  --home /var/lib/haproxy \
  --quiet \
  --group \
  haproxy
