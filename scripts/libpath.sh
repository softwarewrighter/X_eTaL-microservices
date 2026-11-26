#!/usr/bin/env bash
# The library search path, XETAL_PATH (docs/plan.md, M1, M3): this
# repository's libs/*/src, then every library of X_eTaL-libraries at
# this repository's pin (work/xetal-libraries). PREFIX is put before each
# path, which is otherwise relative to the repository's root; none gives
# absolute paths. (X_eTaL-FBP's libraries join here once it has any and
# XETAL_FBP_COMMIT pins it: docs/xetal-FBP-asks.md.)
# Adapted from X_eTaL-manifolds' scripts/libpath.sh (no X_eTaL-ML).
#   scripts/libpath.sh [PREFIX]
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
prefix="${1-$root/}"
cd "$root"
{ ls -d libs/*/src work/xetal-fbp/libs/*/src work/xetal-libraries/libs/*/src 2>/dev/null || true; } | sed "s#^#$prefix#" | paste -sd: -
