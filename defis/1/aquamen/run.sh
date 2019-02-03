#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

./target/release/aquamen ${@}
