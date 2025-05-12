#!/usr/bin/env bash

set -euo pipefail

userdel -r haproxy || true
groupdel haproxy || true
