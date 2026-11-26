# Architecture

How this repository divides a distributed system, what a transaction
is, and what can go wrong between services. The decisions behind it
are in `docs/plan.md` (M1 to M10); the figures it redraws are in
`docs/research-figures.md`.

## Four planes

```
+--------------------------------------------------------------+
| Specification plane (X_eTaL)                                 |
|   contracts, topology, policies, deployment definitions      |
+------------------------------+-------------------------------+
                               v
+--------------------------------------------------------------+
| Control plane (X_eTaL)                                       |<---+
|   discovery | routing | deployment | health                  |    |
+------------------------------+-------------------------------+    |
                               ^ v                                  |
+--------------------------------------------------------------+    |
| Data plane (X_eTaL + Rust)                                   |    |
|   service A --> service B --> service C                      |    |
|   domain transactions and synthetic heartbeats, one path     |    |
+------------------------------+-------------------------------+    |
                               v                                    |
+--------------------------------------------------------------+    |
| Observation plane (X_eTaL + Rust)                            |----+
|   logs, metrics, traces, replay, analysis                    |
+--------------------------------------------------------------+
```

Observation feeds control: what the system sees of itself becomes the
next routing and deployment decision (the MAPE-K loop: monitor,
analyze, plan, execute, over shared knowledge). Each arrow into the
control plane is a pure function here:

| Decision | Function | Library |
| -------- | -------- | ------- |
| which version | `version = route(policy, transaction)` | Rollout |
| which instance | `instance = select(registry, measurements, weights)` | Balance |
| roll back or not | `policy' = decide(policy, metrics, history)` | Rollout |
| healthy or not | `levels = health(heartbeats, expected, window)` | Health |
| what breaks if X fails | `affected = blast(topology, X)` | Topology |
| in what order to deploy | `levels = order(topology)` | Topology |

The data plane's business logic is ordinary X_eTaL; its I/O is a
runtime's (X_eTaL-extensions, later). In this repository's simulations
the runtime is itself a pure step function over virtual time.

## Functional core

A service, a breaker, a saga, a registry: each is a step

```
(s', y, e) = f(s, x)
```

from the state `s` and an input `x` to the new state `s'`, a response
`y` and the effects `e` the runtime is asked to carry out (send these
messages, write these rows, schedule this timer), as data. Nothing is
sent or written inside `f`. So every step can be tested alone, replayed
from a journal, run beside another version on the same input, and
simulated without a network.

## Two levels: components and services

```
+------------- distributed application ----------------------+
|  +-- microservice A ------+     +-- microservice B ------+  |
|  |  FBP subnetwork        |     |  FBP subnetwork        |  |
|  |   component 1          |     |   component 1          |  |
|  |       v                |     |       v                |  |
|  |   component 2 ---------+---->|   component 2          |  |
|  |  private state         |     |  private state         |  |
|  +------------------------+     +------------------------+  |
|            service-to-service message transport            |
+------------------------------------------------------------+
```

| Level | Governed by | Where |
| ----- | ----------- | ----- |
| computation inside a component | X_eTaL's functional array programming | any repository |
| communication between components, composition, scheduling | Morrison's FBP | X_eTaL-FBP |
| business boundaries, data ownership, consistency between services | Richardson, domain-driven design | here |
| deployment, discovery, resilience, operations | Richardson and the operational literature | here |
| system analysis (graphs, matrices of measurements) | X_eTaL arrays | here, on X_eTaL-libraries |

The component network and the deployment are separate tables. Moving
a component across a service boundary changes the transport, the
serialization, the delivery guarantees and the failure outcomes it
sees; it does not change its pure computation. Until X_eTaL-FBP has a
library to pin, programs here work at the service level only: a
service is one step function, a call is one transaction.

## Transactions

"Transaction" means six different things here, which may share
identifiers but are never interchangeable:

| Term | Meaning |
| ---- | ------- |
| information packet | the unit of communication between components (FBP's) |
| domain transaction | one business request or operation |
| ACID transaction | one atomic local database change, inside one service |
| saga | a coordinated sequence of local transactions across services, with compensations |
| trace | the correlated record of distributed activity for one request |
| heartbeat transaction | a synthetic test of the system's behavior along a domain path |

### The envelope

Every domain transaction between services travels in one immutable
envelope (Envelope library, saga 1):

| Field | Purpose |
| ----- | ------- |
| transaction id | this transaction |
| trace id, parent span | where it sits in the trace |
| correlation id | ties a reply to its request |
| schema version | the contract version of the payload |
| class | domain, heartbeat, synthetic, replay or shadow |
| deadline | the time by which an answer is useless |
| idempotency key | so a retried or duplicated delivery is processed once |
| routing epoch | the policy version that routed it |
| experiment cohort | the A/B cohort it belongs to |
| payload | the business content |

Many envelopes are kept as columns (one array per field), not as an
array of records (plan M5). The class is a closed set of small integer
codes. Heartbeat, synthetic, replay and shadow transactions go through
exactly the same services and code as domain ones, but the effect guard
refuses their irreversible effects (payments, shipments, emails): a
test must not bypass what it tests, and must not cause what it only
tests.

## Failure semantics

A local function from A to B does not keep that contract when it
becomes remote: a timeout does not prove that the request was not
carried out. A remote call's result is one of a closed set of
outcomes, never a panic:

| Outcome | Meaning | Safe to retry? |
| ------- | ------- | -------------- |
| ok | carried out; the answer is here | - |
| rejected | the service refused it (a domain rule, a contract) | no: the same request is refused again |
| transport failure | it never reached the service | yes |
| timeout | the deadline passed with no answer | only if idempotent: it may have been carried out |
| unknown | the outcome cannot be known (a connection lost mid-reply) | only if idempotent |

### Three rollbacks

| Rollback | What it does | Undoes committed business effects? |
| -------- | ------------ | ---------------------------------- |
| deployment rollback | traffic back to an earlier version | no |
| database rollback | an uncommitted local change aborted | nothing was committed |
| business compensation | another operation counteracting a committed one (a refund, a release of stock) | yes, by a new transaction |

Withdrawing a version's traffic never undoes what it already did; a
rollback decision that matters for business effects issues
compensations (Sagas, saga 3).

### What arrays do not solve

The functional, array-oriented style makes these explicit and testable;
it does not make them go away. Each has its planned answer:

| Challenge | Approach | Where |
| --------- | -------- | ----- |
| duplicate transactions | idempotency keys and deduplication | Envelope, Messaging |
| lost messages | acknowledgments and delivery policies | Messaging, FBP |
| partial failure | explicit failure outcomes | Envelope |
| slow services | deadlines and cancellation | Envelope, Resilience |
| overload | bounded queues and backpressure | FBP, Resilience |
| retry storms | retry budgets, backoff and jitter | Resilience |
| cascading failure | circuit breakers and bulkheads | Resilience, Topology (blast radius) |
| distributed state | explicit ownership and consistency policies | Sagas, Events |
| cross-service transactions | sagas and compensating actions | Sagas |
| message ordering | per-stream sequence numbers where required | Messaging |
| schema evolution | versioned contracts and compatibility checks | Envelope |
| clock differences | monotonic local clocks and causal metadata | Trace |
| network partition | explicit availability and consistency trade-offs | saga 7 |
| control-plane failure | last-known-good configuration | Rollout |
| security | authentication, authorization, TLS, capabilities | saga 7, extensions |

## Execution backends

One specification, several backends, introduced in this order (plan
principle 3, M7):

| Backend | Purpose | Saga |
| ------- | ------- | ---- |
| pure simulation | deterministic tests, virtual time | 1 |
| FBP network in one process | asynchronous components, bounded connections | 5 |
| local processes | real serialization, crashes, supervision | 7 |
| several hosts (the lab) | network delays and partitions | 7 |
| containers, Kubernetes | optional integration | later |
