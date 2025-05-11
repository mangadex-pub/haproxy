#!/usr/bin/env bash

set -euo pipefail

pkl \
  eval "package://pkg.pkl-lang.org/pkl-pantry/org.json_schema.contrib@1.1.4#/generate.pkl" \
  -m . \
  -p source="https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"
