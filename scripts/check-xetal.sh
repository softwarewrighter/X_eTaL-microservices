#!/usr/bin/env bash
# Check the pinned toolchain (docs/plan.md, M1): the X_eTaL clone is at
# XETAL_COMMIT and the X_eTaL-libraries clone at XETAL_LIBRARIES_COMMIT,
# both unchanged; xetal builds, answers and reports that commit; a
# standard library imports; X_eTaL-libraries' Check and Graphs load.
# Adapted from X_eTaL-manifolds' scripts/check-xetal.sh.
#   scripts/check-xetal.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
xetal="$("$root/scripts/xetal.sh")"
"$root/scripts/xetal-libraries.sh"
pin="$(tr -d '[:space:]' < "$root/XETAL_COMMIT")"
[ "$(git -C "$root/work/xetal" rev-parse HEAD)" = "$pin" ] || { echo "check-xetal: work/xetal is not at $pin" >&2; exit 1; }
[ -z "$(git -C "$root/work/xetal" status --porcelain)" ] || { echo "check-xetal: work/xetal has local changes" >&2; exit 1; }
fail() { echo "check-xetal: $1 gave '$2', expected '$3'" >&2; exit 1; }
got="$("$xetal" eval -e "'+ r_/_2 2 3 r_eshape r_ange 6")"
[ "$got" = "6 15" ] || fail eval "$got" "6 15"
"$xetal" --version | grep -q "Commit: ${pin:0:8}" || { echo "check-xetal: xetal --version does not report ${pin:0:8}" >&2; "$xetal" --version >&2; exit 1; }
got="$("$xetal" eval -e '"s:" u_se< "Stats"
s:m_ean 1 2 3 4')"
[ "$got" = "2.5" ] || fail Stats "$got" 2.5
got="$("$root/scripts/xt" eval -e '"ch:" u_se< "Check"
6 ch:i_s 2 * 3')"
[ "$got" = "ok" ] || fail "Check (X_eTaL-libraries)" "$got" ok
got="$("$root/scripts/xt" eval -e '"g:" u_se< "Graphs"
g:o_utDegree 3 g:a_djacency 2 2 r_eshape 1 1 2 3')"
[ "$got" = "2 0 0" ] || fail "Graphs (X_eTaL-libraries)" "$got" "2 0 0"
libs="$(tr -d '[:space:]' < "$root/XETAL_LIBRARIES_COMMIT")"
echo "check-xetal: ok (X_eTaL ${pin:0:7}, X_eTaL-libraries ${libs:0:7})"
