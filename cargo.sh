#!/usr/bin/env sh

set -eu

TOOL_PATH=${TOOL_PATH:-cargo}

cd rs
"$TOOL_PATH" run
