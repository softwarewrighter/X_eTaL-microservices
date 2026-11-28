#!/usr/bin/env bash
# Get X_eTaL-FBP at this repository's own pin (docs/plan.md, M1):
# clone it into work/xetal-fbp (gitignored) and check out the
# known-good commit in XETAL_FBP_COMMIT. Its libraries go on the
# search path (scripts/libpath.sh, scripts/xt). Never edit the clone.
# X_eTaL-FBP's libraries come before X_eTaL-libraries' on the path, as
# its README asks (they may import them). Made from
# scripts/xetal-libraries.sh, names changed.
#   scripts/xetal-fbp.sh
#   XETAL_FBP_SOURCE=../X_eTaL-FBP scripts/xetal-fbp.sh   # first clone from a local checkout
#   scripts/xetal-fbp.sh --pin [REF]   # pin a committed ref of ../X_eTaL-FBP (default HEAD)
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source="${XETAL_FBP_SOURCE:-https://github.com/softwarewrighter/X_eTaL-FBP.git}"
clone="$root/work/xetal-fbp"
if [ "${1:-}" = --pin ]; then
    repo="${XETAL_FBP_REPO:-$root/../X_eTaL-FBP}"
    sha="$(git -C "$repo" rev-parse --verify "${2:-HEAD}^{commit}")"
    echo "$sha" > "$root/XETAL_FBP_COMMIT"
    # A local commit not yet on GitHub: fetch it into the clone from the sibling.
    if [ -d "$clone/.git" ] && ! git -C "$clone" cat-file -e "$sha^{commit}" 2>/dev/null; then
        git -C "$clone" fetch --quiet "$repo" "$sha" 2>/dev/null || true
    fi
    source="${XETAL_FBP_SOURCE:-$repo}"
    echo "pinned X_eTaL-FBP ${sha:0:7}: $(git -C "$repo" log -1 --format=%s "$sha")" >&2
    echo "fbp-pin: now run everything (just gate --full), then commit XETAL_FBP_COMMIT on its own" >&2
fi
commit="$(tr -d '[:space:]' < "$root/XETAL_FBP_COMMIT")"
if [ ! -d "$clone/.git" ]; then
    mkdir -p "$root/work"
    echo "xetal-fbp: cloning $source into work/xetal-fbp" >&2
    git clone --quiet "$source" "$clone"
fi
if ! git -C "$clone" cat-file -e "$commit^{commit}" 2>/dev/null; then
    git -C "$clone" fetch --quiet origin
fi
if [ "$(git -C "$clone" rev-parse HEAD)" != "$commit" ]; then
    git -C "$clone" checkout --quiet --detach "$commit"
fi
[ -z "$(git -C "$clone" status --porcelain)" ] || { echo "xetal-fbp: work/xetal-fbp has local changes; it must match XETAL_FBP_COMMIT" >&2; exit 1; }
