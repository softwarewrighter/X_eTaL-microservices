# Pattern coverage

Every pattern this repository means to cover, where its coverage will
come from, and how far it has got (docs/plan.md, M9). A pattern is
**covered** only when a tested library function or demo shows it;
**planned** means a library or demo of the roadmap is meant to cover
it; **FBP** means X_eTaL-FBP owns it and this repository uses it
(`docs/xetal-FBP-asks.md`); **later** means no saga has it yet.

Sources: Chris Richardson, *Microservices Patterns* (Manning, 2018),
and his online catalog at microservices.io/patterns (R below); Gregor
Hohpe and Bobby Woolf, *Enterprise Integration Patterns* (E); J. Paul
Morrison, *Flow-Based Programming* (M); the operational literature
(Nygard's *Release It!*, Google's *Site Reliability Engineering*, the
Reactive Streams specification) and the research's own proposals (O).
Pattern names are the sources'; the descriptions here are this
repository's mappings, not quotations. The priorities are the
research's proposal (P0 foundational, P1 early, P2 advanced, P3
optional), adjusted where noted.

## Richardson: application architecture and decomposition

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Monolithic architecture | R | P0 | a whole network in one process: the simulation's default placement | poc demo | 1 | planned |
| Microservice architecture | R | P0 | independently deployed units; a deployment table separate from the component network | poc demo, `d_eploy<` | 1, 5 | planned |
| Decompose by business capability | R | P1 | services grouped by responsibility; Topology measures the coupling a grouping leaves | Topology | 5 | planned |
| Decompose by subdomain | R | P1 | domain boundaries and ownership columns on the service table | Topology | 5 | planned |
| Self-contained service | R | P1 | a service's synchronous dependencies counted: none needed to answer | Topology | 5 | planned |
| Service per team | R | P3 | an owner column; edges crossing owners counted | Topology | 5 | later |
| Strangler application | R | P2 | Rollout's split between a legacy and a new implementation, per route | Rollout | 3 | planned |
| Anti-corruption layer | R | P1 | a pure translation function at a boundary, contract checked both sides | Envelope | 3 | planned |

## Richardson: communication

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Remote procedure invocation | R | P1 | request/response with typed outcomes (ok, rejected, transport failure, timeout, unknown) | Envelope | 1 | planned |
| Messaging | R | P0 | asynchronous streams of packets; at the service level, messages between services | FBP; Messaging | 2 | FBP |
| Domain-specific protocol | R | P2 | a gateway to a GPU, FPGA or other service by a native extension | extensions | 7 | later |
| Idempotent consumer | R | P1 | an idempotency key and a seen-set: duplicates answered from the record, not processed again | Envelope, Messaging | 1, 2 | planned |

## Richardson: service discovery

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Service registry | R | P1 | a table of instances: service, version, health, load, locality, capacity | Balance | 1 | planned |
| Client-side discovery | R | P1 | the caller evaluates the routing policy over the registry | Balance, Rollout | 1 | planned |
| Server-side discovery | R | P1 | a router (the gateway) evaluates the same policy | Balance, Rollout | 1 | planned |
| Self registration | R | P1 | an instance adds its row; a registration step of the registry state | Balance | 2 | planned |
| Third-party registration | R | P2 | a supervisor adds and removes rows from health observations | Health | 2 | planned |

## Richardson: reliability (with the research's additions)

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Circuit breaker | R | P1 | a state machine (closed, open, half-open) over a window of outcomes | Resilience | 2 | planned |
| Bulkhead | O | P1 | a concurrency limit per dependency; work over the limit rejected | Resilience | 2 | planned |
| Retry with backoff and jitter | O | P1 | a schedule of delays from a seed; retry only what is safe to retry | Resilience | 2 | planned |
| Retry budget | O | P1 | retries as a share of first attempts over a window | Resilience | 2 | planned |
| Deadline and cancellation | O | P1 | a deadline in the envelope, checked at each hop | Envelope | 1 | planned |
| Rate limiting, load shedding | O | P1 | a token bucket; lowest-priority work shed first | Resilience | 2 | planned |
| Bounded queues, backpressure | M | P0 | bounded connections and their overflow policies | FBP | 5 | FBP |

## Richardson: external APIs

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| API gateway | R | P1 | the entry point: protocol to envelope, routing, composition | poc demo | 1 | planned |
| Backend for frontend | R | P2 | one gateway per client kind over the same services | Topology | 5 | later |

## Richardson: data management

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Database per service | R | P1 | each service's state private to its step function | Sagas, Events | 3 | planned |
| Shared database | R | P2 | the coupling it adds, counted on the topology | Topology | 3 | later |
| Saga (orchestration) | R | P1 | `(s', c) = f(s, e)`: a state machine issuing commands, compensations on failure | Sagas | 3 | planned |
| Saga (choreography) | R | P1 | each service reacts to domain events; the same requirement as the orchestrated one | Sagas | 3 | planned |
| Command-side replica | R | P2 | a local copy of remote data kept by events | Events | 3 | later |
| API composition | R | P1 | fan-out queries, a join of the answers, partial answers typed | Events | 3 | planned |
| CQRS | R | P1 | commands to events, events folded into query views | Events | 3 | planned |
| Domain event | R | P0 | an immutable record of what happened, by class and key | Envelope, Events | 1, 3 | planned |
| Event sourcing | R | P1 | state as a fold (a reduce) of its events; snapshots | Events | 3 | planned |

## Richardson: transactional messaging

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Transactional outbox | R | P1 | a step returns the state change and the pending messages together, applied atomically | Messaging | 2 | planned |
| Polling publisher | R | P1 | a periodic step that publishes pending outbox rows and marks them | Messaging | 2 | planned |
| Transaction log tailing | R | P2 | messages derived from a log of committed changes | Messaging | 2 | later |

## Richardson: testing

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Service component test | R | P0 | a service's pure step tested alone with controlled inputs | every library | 1 | planned |
| Consumer-driven contract test | R | P1 | consumers' expectations as data, checked against the provider's contract | Envelope | 3 | planned |
| Consumer-side contract test | R | P1 | the consumer's assumptions checked against the contract | Envelope | 3 | planned |
| Deterministic simulation test | O | P0 | seeded workloads and faults, baselines of the whole run | poc demo | 1 | planned |
| Differential test, replay | O | P2 | two versions on identical recorded inputs, outputs compared | Rollout, Trace | 8 | later |

## Richardson: deployment

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Multiple service instances per host | R | P1 | several instance rows on one host; host capacity shared | Balance | 7 | planned |
| Service instance per host | R | P1 | one row per host | Balance | 7 | planned |
| Service instance per VM | R | P2 | a placement column | runtime | 7 | later |
| Service instance per container | R | P2 | a placement column; OCI by an extension | runtime | 7 | later |
| Serverless deployment | R | P3 | instances started per event | runtime | 7 | later |
| Service deployment platform | R | P2 | supervision and placement as policies | runtime | 7 | later |

## Richardson: cross-cutting concerns

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Microservice chassis | R | P0 | the common Rust host that runs X_eTaL services (asked of X_eTaL-extensions); in simulation, the step driver | poc demo, extensions | 1, 7 | planned |
| Service template | R | P1 | a recipe that starts a service's library and tests | tooling | 7 | later |
| Externalized configuration | R | P0 | policies and topology as data, versioned apart from the services | Rollout | 1 | planned |

## Richardson: security

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Access token | R | P1 | an authorization context carried in the envelope, checked per port | Envelope | 7 | later |
| Service identity, mutual TLS | O | P2 | by an extension | extensions | 7 | later |

## Richardson: observability

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Log aggregation | R | P1 | structured events from every service, one table | Trace | 4 | planned |
| Application metrics | R | P1 | windowed reductions of measurements | Health, Trace | 1, 4 | planned |
| Audit logging | R | P1 | an append-only record of business actions | Events | 3 | planned |
| Distributed tracing | R | P1 | spans with parent ids to a trace; the critical path | Trace | 4 | planned |
| Exception tracking | R | P1 | failures grouped by service and version | Trace | 4 | planned |
| Health check API | R | P1 | liveness and readiness | Health | 1 | planned |
| Log deployments and changes | R | P1 | deployment events beside the metrics they explain | Rollout, Trace | 4 | planned |
| In-band heartbeat transactions | O | P1 | synthetic transactions along the domain paths, path and semantic health | Health | 1 | planned |

## Richardson: UI composition

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| Server-side page fragment composition | R | P3 | pages composed from fragments | pages | 6 | later |
| Client-side UI composition | R | P3 | the same, in the browser | pages | 6 | later |

## Progressive deployment (the research's additions)

| Pattern | Src | Pri | X_eTaL mapping | Coverage | Saga | Status |
| ------- | --- | --- | -------------- | -------- | ---- | ------ |
| A/B testing | O | P1 | stable cohorts by a hash of a key; outcomes compared per cohort | Rollout | 1 | planned |
| Canary deployment | O | P1 | a schedule of candidate weights, advanced by the metrics | Rollout | 1 | planned |
| Blue/green | O | P1 | the whole weight moved at once, the old kept ready | Rollout | 1 | planned |
| Shadow execution | O | P1 | the candidate runs beside; its answer compared, never returned | Rollout | 1 | planned |
| Fallback | O | P1 | a compatible alternative after a failure outcome | Resilience | 2 | planned |
| Dynamic rollback | O | P2 | P' = f(P, M, H), with a minimum sample and hysteresis | Rollout | 1 | planned |
| Rolling update | O | P2 | instances replaced a few at a time | Balance, Rollout | 2 | planned |
| Version routing | O | P1 | version chosen first, instance second | Rollout, Balance | 1 | planned |

## Enterprise Integration Patterns

| Family | Patterns | Src | Coverage | Saga | Status |
| ------ | -------- | --- | -------- | ---- | ------ |
| Channels | point-to-point, publish/subscribe, dead letter channel, invalid message channel, guaranteed delivery | E | FBP (connections); Messaging (dead letter, delivery) | 2, 5 | planned |
| Construction | command message, event message, document message, request/reply, correlation identifier, return address, message expiration | E | Envelope | 1 | planned |
| Routing | content-based router, message filter, recipient list, splitter, aggregator, resequencer, scatter/gather, routing slip, process manager | E | FBP (components); the process manager is Sagas | 3, 5 | FBP |
| Transformation | message translator, envelope wrapper, content enricher, content filter, normalizer, canonical data model | E | FBP (components); Envelope (wrapper) | 1, 5 | FBP |
| Endpoints | polling consumer, event-driven consumer, competing consumers, selective consumer, idempotent receiver, transactional client, service activator | E | Balance (competing consumers), Messaging, Envelope | 1, 2 | planned |
| Management | wire tap, message history, control bus, test message, detour, smart proxy, channel purger | E | Trace (wire tap, history), Health (test message), Rollout (control bus) | 1, 4 | planned |

## Morrison's FBP, as this repository uses it

All owned by X_eTaL-FBP (docs/plan.md, M3 b); listed so that the
microservices' requirements of each are visible
(`docs/xetal-FBP-asks.md`).

| Concept | Src | What this repository needs of it | Status |
| ------- | --- | -------------------------------- | ------ |
| Information packet | M | metadata beside the payload (trace id, class, deadline), kept across a service boundary | FBP |
| Named ports, array ports | M | a port's contract readable as data, for contract checks across services | FBP |
| Connection, bounded buffer | M | capacity and overflow policy as data; a connection marked local or remote | FBP |
| Network definition | M | the network as tables (processes, ports, connections), so a deployment can partition it | FBP |
| Subnetwork | M | a subnetwork's exported ports as a service's interface | FBP |
| Initial information packet | M | per-instance configuration (a version's parameters) | FBP |
| Substreams, bracket packets | M | batches and grouped replies | FBP |
| Scheduler | M | deterministic, seeded, virtual time, so service simulations run on it | FBP |
| Checkpoint | M | a component's state captured for replay | FBP |
| Deadlock analysis | M | wait-for graphs across service boundaries | FBP |

## Counts

| Group | Rows | Covered | Planned | FBP | Later |
| ----- | ---- | ------- | ------- | --- | ----- |
| Richardson (with additions) | 64 | 0 | 46 | 2 | 16 |
| Progressive deployment | 8 | 0 | 8 | 0 | 0 |
| Enterprise Integration Patterns | 6 | 0 | 4 | 2 | 0 |
| Morrison's FBP | 10 | 0 | 0 | 10 | 0 |
