# X_eTaL-microservices: plan

Distributed application architecture in X_eTaL: the microservice
patterns of Chris Richardson's *Microservices Patterns* (and its online
catalog), Enterprise Integration Patterns and the operational
literature (resilience, progressive deployment, observability), written
as X_eTaL specifications, policies and simulations, on top of the
flow-based programming (FBP) of J. Paul Morrison, which lives in its
own repository, X_eTaL-FBP.

The research behind it is `docs/research.txt` (with its figures in
`docs/research-figures.md`), archival and not normative: this plan
says what is adopted.

## The question

Can an array-oriented functional language represent an entire
distributed system as executable, analyzable and transformable data,
and can the same specification be used to simulate that system,
deploy it, monitor it, debug it, experiment with it and adapt it?

## Principles

1. **Policies in X_eTaL, mechanisms in Rust.** Where a transaction
   goes, whether a version is rolled back, whether a breaker opens: pure
   X_eTaL functions over arrays. Sockets, async I/O, processes, TLS,
   persistence: Rust, in X_eTaL-extensions, asked for, not written here.
2. **Functional core, imperative shell.** Every stateful thing here is
   a pure step `(s', y, e) = f(s, x)`: the state, the input, the new
   state, the response, and the effects the runtime is asked to
   perform, as data. Nothing in a library here performs I/O.
3. **Simulate before distributing.** The same specification runs in a
   deterministic simulation (virtual clock, fixed seeds) first; real
   processes and hosts are later, interchangeable backends.
4. **Distribution is a semantic boundary.** A remote call is not a
   local call: it has typed outcomes (success, rejection, transport
   failure, timeout, unknown), deadlines, duplicates and partial
   failure. These are explicit values, never panics.
5. **Component topology is not deployment topology.** FBP networks
   compose components inside a service; Richardson's patterns govern
   between services. A network of 100 components may be one, five or
   twenty services.
6. **Each phase ends in something that runs and is tested**, never in
   infrastructure waiting for a distant application.

## Architecture decisions

**M1. Pins and dependency direction.** X_eTaL is used only at
`XETAL_COMMIT` (X_eTaL's `docs/vendoring.md`): `just xetal` clones it
into the gitignored `work/xetal/` and links `bin/xetal`. X_eTaL-libraries
is used at `XETAL_LIBRARIES_COMMIT`, cloned into `work/xetal-libraries/`.
X_eTaL-FBP will be pinned the same way (`XETAL_FBP_COMMIT`,
`work/xetal-fbp/`, already on the search path in `scripts/libpath.sh`)
once it has a library to use; today it holds only the research. The
direction is one way: this repository depends on X_eTaL-FBP,
X_eTaL-libraries and X_eTaL; none of them ever depends on this one.
(The research's page 64 also allows a direct use of X_eTaL-extensions.)
A pin moves at a saga start or when an ask has landed, never mid-step,
one pin at a time, in its own commit after the gate. The first pins:
X_eTaL `8c49bd8` (the commit X_eTaL-libraries is known good with) and
X_eTaL-libraries `c7e812e` (its head, 2026-11-24). X_eTaL moved to
`ba6406b` on 2026-11-26, between steps 3 and 4, ahead of the commit
X_eTaL-libraries pins (`8c49bd8`): Graphs and Check pass the gate there,
and the only change here was simpler inferred types (X_eTaL's T10).

**M2. The four planes.** Specification (contracts, topology, policies,
deployment), control (discovery, routing, deployment, health), data
(the services, domain transactions and heartbeats together) and
observation (logs, metrics, traces, replay), with observation feeding
control (research page 4). Libraries here are mostly control-plane and
observation-plane functions; the data plane's domain logic is ordinary
X_eTaL.

**M3. Where a function lives.** A function a program needs goes:
a. particular to distributed services (routing, rollout, health,
   envelopes, sagas, outboxes, traces): a library here, `libs/<Name>/`;
b. about FBP itself (information packets, ports, connections, bounded
   buffers, backpressure, schedulers, subnetworks, network
   definitions, substreams): X_eTaL-FBP, by an ask in
   `docs/xetal-FBP-asks.md`. **Never duplicated here**; until it lands
   a program here works at the level of whole transactions and service
   calls, not of ports and packets;
c. general (graphs, statistics, hashing, text): X_eTaL-libraries, by an
   ask in `docs/xetal-libraries-asks.md`;
d. native code (networking, processes, clocks, persistence):
   X_eTaL-extensions, by an ask in `docs/xetal-extensions-asks.md`;
e. only when none of those can: `docs/xetal-asks.md`, a change to the
   language, with why a to d fail.
Each ask: status, kind, who needs it, why, a minimal example, the
workaround in use. A workaround is written out where it is used and
named in the ask; nothing outside this repository is changed from here.

**M4. Tests.** Each library has reg-rs baselines (`tests/*.rgt` with
`.out`/`.err`, the exports' types in `types.rgt`, each demo's output),
checks written with X_eTaL-libraries' `Check` (`ch:i_s`, `ch:n_ear`), and
doc-comment examples (`## >>`) run by `xetal doc --test`. Where a figure
of the research carries numbers (`docs/research-figures.md`) they are a
fixture: the load balancer's costs (page 15) and the canary's error rate
(page 13) are reproduced exactly. `just gate` runs it all, with American
spelling and ASCII markdown checks, before every commit.

**M5. Data, array first** (X_eTaL's `docs/adt.md`, X_eTaL-libraries' plan
A13). Many things of one kind are columns, not records: an instance
table is a matrix of measurements (one row per instance) and a mask; a
topology is a matrix (connectivity A, latency L, throughput T, error E,
capacity C, queue Q, routing weight R) or an edge table of columns. One
state of parts of different types is a tuple with accessor functions.
A closed set of kinds (transaction classes, outcomes, breaker states)
is a small integer code with named constants, never a dynamic type.

**M6. Macros only where they solve a problem** (the user's rule in
X_eTaL-libraries): reading names from source text and making named
definitions, e.g. a `t_opology<` that names services as variables, as
Graphs' `g_raph<` does for stations; later `s_ervice<`, `p_olicy<`,
`d_eploy<`. Never before the functions they expand to exist and are
tested.

**M7. Deterministic simulation.** A simulation is a function of its
inputs and a seed: virtual time in integer milliseconds or ticks,
workloads as arrays, randomness from a seeded generator. The same
inputs give the same baseline.

**M8. Three rollbacks, five transaction classes.** Deployment rollback
(traffic back to an earlier version), database rollback (an
uncommitted local change aborted) and business compensation (another
operation counteracting a committed one) are different functions and
never conflated. Transactions are of class domain, heartbeat,
synthetic, replay or shadow; a non-domain transaction travels the same
path but its irreversible effects are refused by the effect guard.

**M9. Pattern catalog.** `docs/patterns.md` is the coverage matrix:
every pattern of Richardson's catalog, the Enterprise Integration
Patterns families and the operational additions, with its priority (P0
to P3), the library or demo that covers it, and its status. A pattern
is "covered" only with a tested library function or demo.

**M10. Demos and pages, later.** A demo is `demos/<slug>/` with its
program and baselines. Pages follow the siblings: built into `pages/`
(not tracked), published as `gh-pages`; X_eTaL computes every number a
page shows, Rust or JavaScript only lays it out. This repository's
local port is **8491**. The first page is the Service Deployment
Explorer (research page 71).

## Libraries (planned)

| Library | Alias | What | Saga |
| ------- | ----- | ---- | ---- |
| Topology | `tp:` | a service graph from an edge table: fan-in, fan-out, dependency cycles, blast radius, deployment order, orphans, critical paths; on Graphs | 1 |
| Balance | `lb:` | instance selection: health masks, weighted least cost, round robin, weighted round robin, least outstanding, power of two choices, consistent hashing | 1 |
| Rollout | `ro:` | version routing: traffic split, stable A/B cohorts, canary steps, shadow, blue/green; the rollback decision P' = f(P, M, H) | 1 |
| Envelope | `tx:` | the transaction envelope (ids, class, deadline, idempotency key, routing epoch, cohort), typed outcomes, the effect guard | 1 |
| Health | `hl:` | the five health levels, heartbeat generation and semantic verification | 1 |
| Resilience | `rs:` | circuit breaker, retry budget, backoff and jitter, bulkhead, deadline, load shedding | 2 |
| Messaging | `ms:` | idempotent consumer, transactional outbox, polling publisher, dead letter | 2 |
| Sagas | `sg:` | orchestration as a state machine, choreography, compensation | 3 |
| Events | `ev:` | event sourcing (state from events), CQRS projections, API composition | 3 |
| Trace | `tr:` | spans to a trace, critical path, log aggregation, SLO windows | 4 |

## Sagas (roadmap)

Saga numbers follow the research's revised roadmap (its section 14)
regrouped by what can be built before X_eTaL-FBP delivers.

1. **foundation** (this saga): the repository, the pattern coverage
   matrix and architecture, and the first control-plane libraries,
   ending in the research's first proof of concept as a pure
   simulation. Steps:
   1. `setup`: scaffold, pins, gate, plan, asks files, saga.
   2. `patterns`: `docs/patterns.md` (coverage matrix),
      `docs/architecture.md` (planes, levels, transaction model,
      failure semantics), FBP interface requirements in
      `docs/xetal-FBP-asks.md`.
   3. `topology`: libs/Topology, with the order-processing graph of
      pages 6 and 8 as its fixture.
   4. `balance`: libs/Balance, with page 15 as its fixture.
   5. `rollout`: libs/Rollout, with page 13 as its fixture.
   6. `envelope`: libs/Envelope, typed outcomes and the effect guard.
   7. `health`: libs/Health, heartbeats and the five levels.
   8. `poc`: `demos/service-deployment`, the research's first proof of
      concept (page 28): services A -> B -> C, two versions of B (one
      slower or sometimes wrong), a mixed workload of domain and
      heartbeat transactions, latency, throughput and correctness
      measured, the bad version withdrawn automatically. A pure,
      seeded simulation at the level of service calls.
2. **reliability**: Resilience and Messaging; fault injection in the
   simulation.
3. **data**: Sagas and Events; orchestration and choreography on the
   same business requirement (pages 50, 51).
4. **observability**: Trace; the trace of page 18 as a fixture; the
   MAPE-K loop (page 20).
5. **FBP**: pin X_eTaL-FBP; a deployment specification that partitions
   an FBP network into services (`d_eploy<`, page 53); the proof of
   concept re-hosted on FBP networks. Waits on X_eTaL-FBP.
6. **pages**: the Service Deployment Explorer, then the load balancing,
   topology and heartbeat explorers.
7. **runtime**: the Rust chassis by asks to X_eTaL-extensions; local
   processes, then the lab's hosts.
8. **adaptive**: replay, differential replay, distributed debugging,
   autonomous policies.

## Settled

- 2026-11-24: X_eTaL-FBP is a separate repository worked on elsewhere;
  this one may depend on it, never the reverse (the user).
- 2026-11-24: commit to `main` and push after every step (the user).
