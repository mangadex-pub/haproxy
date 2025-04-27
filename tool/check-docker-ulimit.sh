#!/usr/bin/env bash

if [ "$(ulimit -n)" = "1073741816" ]; then
    echo "Bad Docker ulimit: $(ulimit -n)..."
    exit 1
else
    echo "ulimit -n = $(ulimit -n)"
fi
