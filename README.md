# X_eTaL-microservices

Microservices and distributed application architecture in X_eTaL (the
eXperimental Extensible Typed Array Language,
[softwarewrighter/X_eTaL](https://github.com/softwarewrighter/X_eTaL)):
service contracts, topologies, routing and load balancing, progressive
deployment (A/B, canary, shadow, rollback), resilience, sagas, event
sourcing, heartbeat transactions and tracing, written as X_eTaL
specifications and policies and run first as deterministic
simulations.

The question it explores: can an array-oriented functional language
describe a whole distributed system as executable, analyzable data, so
that the same specification can be simulated, deployed, monitored,
debugged and adapted?

- **Policies in X_eTaL, mechanisms in Rust.** Where a transaction goes,
  when a version is rolled back, when a breaker opens: pure X_eTaL
  functions over arrays. Networking and processes come later, from
  [X_eTaL-extensions](https://github.com/softwarewrighter/X_eTaL-extensions).
- **Built on flow-based programming.** Components, ports and bounded
  connections come from
  [X_eTaL-FBP](https://github.com/softwarewrighter/X_eTaL-FBP) (J. Paul
  Morrison's FBP); this repository adds the service level above it
  (Chris Richardson's *Microservices Patterns*, Enterprise Integration
  Patterns). General functions come from
  [X_eTaL-libraries](https://github.com/softwarewrighter/X_eTaL-libraries).

## Status

New. The plan, the architecture decisions and the roadmap are in
[`docs/plan.md`](docs/plan.md); the research behind them is
[`docs/research.txt`](docs/research.txt) with its figures in
[`docs/research-figures.md`](docs/research-figures.md).

- [`docs/architecture.md`](docs/architecture.md) -- the four planes,
  components and services, the transaction envelope, failure outcomes
  and the three kinds of rollback
- [`docs/patterns.md`](docs/patterns.md) -- every pattern covered or
  planned (Richardson's catalog, Enterprise Integration Patterns,
  progressive deployment, what comes from FBP), and its status

## Libraries

None yet; planned: Topology, Balance, Rollout, Envelope, Health
([`docs/plan.md`](docs/plan.md), "Libraries").

## Build and test

Needs Rust (cargo), [just](https://github.com/casey/just),
[uv](https://docs.astral.sh/uv/), reg-rs and sw-markdown-checker.

```bash
just xetal            # clone and build X_eTaL at XETAL_COMMIT, get X_eTaL-libraries at its pin (once)
just xetal-version    # the pins
just eval "'+ r_/ 1 2 3"
just test             # every library's baselines
just gate             # everything checked before a commit
```

X_eTaL and X_eTaL-libraries are cloned into `work/` (not tracked) at
the commits in `XETAL_COMMIT` and `XETAL_LIBRARIES_COMMIT`;
`just xetal-pin` and `just libs-pin` move them.

## Related

- [X_eTaL](https://github.com/softwarewrighter/X_eTaL) -- the language
- [X_eTaL-FBP](https://github.com/softwarewrighter/X_eTaL-FBP) --
  flow-based programming in X_eTaL, the foundation this builds on
- [X_eTaL-libraries](https://github.com/softwarewrighter/X_eTaL-libraries)
  -- general X_eTaL libraries
- [X_eTaL-extensions](https://github.com/softwarewrighter/X_eTaL-extensions)
  -- native extensions

## Links

- Blog: [Software Wrighter Lab](https://software-wrighter-lab.github.io/)
- Discord: [Join the community](https://discord.com/invite/Ctzk5uHggZ)
- YouTube: [Software Wrighter](https://www.youtube.com/@SoftwareWrighter)

## Copyright

Copyright (c) 2026 Michael A Wright

## License

MIT. See [`LICENSE`](LICENSE) and [`COPYRIGHT`](COPYRIGHT).
