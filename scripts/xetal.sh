#!/usr/bin/env bash
# Get xetal (X_eTaL's docs/vendoring.md): clone X_eTaL into work/xetal
# (gitignored), check out the known-good commit in XETAL_COMMIT, build
# the release CLI, and link bin/xetal to it. Prints the binary's path.
# Safe to run again: with nothing to do it only confirms the build.
# Never edit the clone; move the pin with `just xetal-pin`.
#   scripts/xetal.sh
#   XETAL_SOURCE=../X_eTaL scripts/xetal.sh   # first clone from a local checkout
#   scripts/xetal.sh --pin [REF]              # pin a committed ref of ../X_eTaL (default HEAD)
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source="${XETAL_SOURCE:-https://github.com/softwarewrighter/X_eTaL.git}"
clone="$root/work/xetal"
if [ "${1:-}" = --pin ]; then
    repo="${XETAL_REPO:-$root/../X_eTaL}"
    sha="$(git -C "$repo" rev-parse --verify "${2:-HEAD}^{commit}")"
    echo "$sha" > "$root/XETAL_COMMIT"
    if [ -d "$clone/.git" ] && ! git -C "$clone" cat-file -e "$sha^{commit}" 2>/dev/null; then
        git -C "$clone" fetch --quiet "$repo" "$sha" 2>/dev/null || true
    fi
    source="${XETAL_SOURCE:-$repo}"
    echo "pinned X_eTaL ${sha:0:7}: $(git -C "$repo" log -1 --format=%s "$sha")" >&2
    echo "xetal-pin: now run just gate --full, then commit XETAL_COMMIT on its own" >&2
fi
commit="$(tr -d '[:space:]' < "$root/XETAL_COMMIT")"
if [ ! -d "$clone/.git" ]; then
    mkdir -p "$root/work"
    echo "xetal: cloning $source into work/xetal" >&2
    git clone --quiet "$source" "$clone"
fi
if ! git -C "$clone" cat-file -e "$commit^{commit}" 2>/dev/null; then
    git -C "$clone" fetch --quiet origin
fi
if [ "$(git -C "$clone" rev-parse HEAD)" != "$commit" ]; then
    git -C "$clone" checkout --quiet --detach "$commit"
fi
bin="$clone/target/release/xetal"
stamp="$root/work/xetal.built"
if [ ! -x "$bin" ] || [ "$(cat "$stamp" 2>/dev/null)" != "$commit" ]; then
    (cd "$clone/components/cli" && cargo build --quiet --release -p xetal-cli) >&2
    echo "$commit" > "$stamp"
fi
mkdir -p "$root/bin"
ln -sfn "../work/xetal/target/release/xetal" "$root/bin/xetal"
echo "$bin"
