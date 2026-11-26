# Changes

Every commit, newest first, grouped by day. Times are Pacific
(UTC-08:00), as committed.

Categories: `feat` new capability, `fix` a bug or wrong behavior,
`refactor` structure without behavior change, `test` tests only,
`build` build and tooling, `lib` a library or a change to one, `demo` a
demo or a change to one, `docs` documentation, `plan` saga planning and
reordering, `release` milestone release, `chore` agentrail bookkeeping
(step complete, saga archive), `pin` a move of the X_eTaL,
X_eTaL-libraries or X_eTaL-FBP pin.

## 2026-11-25

- `build` the repository scaffolded after X_eTaL-manifolds and X_eTaL-games (step setup): `CLAUDE.md` (agentrail's briefing, then this repository's rules: nothing outside it changed, one-way dependencies on X_eTaL-FBP, X_eTaL-libraries, X_eTaL-extensions and X_eTaL, each function where it belongs, FBP's abstractions never duplicated, port 8491) with `AGENTS.md` a link to it; `.gitignore`; `justfile`; `scripts/` (xetal.sh builds X_eTaL at `XETAL_COMMIT` 8c49bd8, the commit X_eTaL-libraries is known good with, rebuilding only when the pin moves; xetal-libraries.sh at `XETAL_LIBRARIES_COMMIT` c7e812e; xt, libpath.sh, py, check-xetal.sh, test-libs.sh, doc-test.sh, check-spelling.py, gate.sh, each saying what sibling script it was adapted from); `docs/plan.md` (principles, decisions M1 to M10, the planned libraries Topology, Balance, Rollout, Envelope, Health, Resilience, Messaging, Sagas, Events, Trace, and eight sagas) from the research in `../X_eTaL-FBP/docs/research.pdf`, kept as `docs/research.txt` with its figures, which the text loses, described in `docs/research-figures.md` (the load balancer's costs and the canary's error rate become fixtures; the normalization behind page 15's costs, which the chart does not state, worked out and checked); the asks files for X_eTaL-FBP (its first library, to pin), X_eTaL-libraries, X_eTaL-extensions and X_eTaL; README with the Copyright and License sections; the agentrail saga `foundation`, eight steps
