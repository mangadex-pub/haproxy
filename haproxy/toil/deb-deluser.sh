#!/usr/bin/env bash

set -euo pipefail

deluser --system haproxy || true
delgroup --system haproxy || true
