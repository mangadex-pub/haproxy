#!/usr/bin/env bash

set -euo pipefail

adduser \
  --system \
  --create-home \
  --home-dir /var/lib/haproxy \
  --user-group \
  haproxy
