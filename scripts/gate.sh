#!/usr/bin/env bash
# The pre-commit gate: the pinned toolchain, every library's baselines
# and doc examples, then the cheap checks (literal c_at chains, American
# spellings, ASCII markdown). Run before every commit and before
# `agentrail complete`. Everything is checked every time while the
# repository is small; an --affected mode, as the siblings have, comes
# when a full run gets slow (docs/plan.md, M4).
# Adapted from X_eTaL-manifolds' scripts/gate.sh (no demos or pages yet).
#   scripts/gate.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
step() { printf '==> %s\n' "$*"; }
step "the pinned toolchain"
scripts/check-xetal.sh
if ls libs/*/src >/dev/null 2>&1; then
  step "the libraries"
  scripts/test-libs.sh
  step "their doc examples"
  scripts/doc-test.sh
fi
step "the cheap checks"
# Concise X_eTaL: number literals strand, so a shape is written
# 8 13 2 r_eshape x, never (8 c_at 13 c_at 2) r_eshape x.
xfiles=$(git ls-files '*.xtl' '*.xtlm'; git ls-files --others --exclude-standard '*.xtl' '*.xtlm')
if [ -n "$xfiles" ] && grep -n -E '\(([0-9]+ c_at )+[0-9]+\)' $xfiles; then
  echo "FAIL: literal c_at chains (write the numbers side by side)"; exit 1
fi
scripts/py scripts/check-spelling.py --self-test
scripts/py scripts/check-spelling.py
# ASCII-only markdown: every .md tracked or new, but CLAUDE.md (AGENTS.md
# is its link; the agentrail briefing it holds is not ASCII) and the saga's.
md=()
while IFS= read -r f; do
  case "$f" in CLAUDE.md|AGENTS.md|.agentrail/*|.agentrail-archive/*|work/*|pages/*) continue ;; esac
  md+=("$f")
done < <({ git ls-files '*.md'; git ls-files --others --exclude-standard '*.md'; } | sort -u)
for f in ${md[@]+"${md[@]}"}; do sw-markdown-checker -f "$f" >/dev/null || { sw-markdown-checker -f "$f"; exit 1; }; done
echo "markdown: ok (${#md[@]} files)"
echo "gate: ok (${SECONDS}s)"
