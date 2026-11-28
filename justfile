# X_eTaL-microservices tasks. Recipes call scripts/*.sh, which hold the
# logic and work without just too. `just` alone lists the recipes.

set positional-arguments

# List the recipes
default:
    @just --list

# Get and build xetal at XETAL_COMMIT (work/xetal, bin/xetal), X_eTaL-libraries at XETAL_LIBRARIES_COMMIT (work/xetal-libraries) and X_eTaL-FBP at XETAL_FBP_COMMIT (work/xetal-fbp)
xetal:
    @scripts/xetal.sh >/dev/null
    @scripts/xetal-libraries.sh
    @scripts/xetal-fbp.sh

# Pin a newer X_eTaL: a committed ref of ../X_eTaL (default HEAD) into XETAL_COMMIT, built; then just gate and commit it alone
xetal-pin ref="HEAD":
    scripts/xetal.sh --pin "$1" >/dev/null

# Pin a newer X_eTaL-libraries: a committed ref of ../X_eTaL-libraries (default HEAD); then just gate and commit it alone
libs-pin ref="HEAD":
    scripts/xetal-libraries.sh --pin "$1"

# Pin a newer X_eTaL-FBP: a committed ref of ../X_eTaL-FBP (default HEAD); then just gate and commit it alone
fbp-pin ref="HEAD":
    scripts/xetal-fbp.sh --pin "$1"

# The pins and the binary's own report
xetal-version:
    @echo "XETAL_COMMIT $(cat XETAL_COMMIT)"
    @echo "XETAL_LIBRARIES_COMMIT $(cat XETAL_LIBRARIES_COMMIT)"
    @echo "XETAL_FBP_COMMIT $(cat XETAL_FBP_COMMIT)"
    @scripts/xt --version

# Evaluate an expression with the pinned xetal, every library on XETAL_PATH: just eval "'+ r_/ 1 2 3"
eval expr:
    @scripts/xt eval -e "$1"

# The library search path: export XETAL_PATH="$(just path)"
path:
    @scripts/libpath.sh

# The REPL, every library importable
repl:
    @scripts/xt repl

# Check the pinned toolchain: the clones at the pins, the CLI answers and reports its commit, Check and Graphs load
check-xetal:
    scripts/check-xetal.sh

# Run a library's test programs (or one): just run-lib Balance basics
run-lib name program="":
    @cd libs/$1/tests && for p in ${2:-*}; do p="${p%.xtl}"; echo "== $p"; ../../../scripts/xt run "$p.xtl"; done

# Run a library's demos (or one): just demo Balance
demo name program="":
    @cd libs/$1/tests && for p in ../demos/${2:-*}; do p="${p%.xtl}"; echo "== $(basename "$p")"; ../../../scripts/xt run "$p.xtl"; done

# Test the libraries (or the named ones): reg-rs baselines, pinned types, expansions
test *names:
    scripts/test-libs.sh "$@"

# Accept a library's current output as its baselines, creating missing ones (review the diff!)
bless name:
    XETAL_BLESS=1 scripts/test-libs.sh "$1"

# Run every ## >> example in the libraries' doc comments (xetal doc --test)
doc-test *names:
    scripts/doc-test.sh "$@"

# The pre-commit gate: toolchain, libraries, doc examples, spelling, markdown
gate:
    scripts/gate.sh

# Show the agentrail saga state
status:
    agentrail status

# Rewrite docs/patterns.md's counts from its rows (the gate checks they agree)
patterns:
    scripts/py scripts/patterns.py --write
