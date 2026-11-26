# The research's figures

`docs/research.txt` is the text of `../X_eTaL-FBP/docs/research.pdf`;
pdftotext keeps a figure's labels but loses its layout, its arrows and
the numbers of its charts. This page records each figure: what it
shows, and the numbers it carries, which become test fixtures here
(docs/plan.md, M4) when they can be reproduced. Archival, like the
text: `docs/plan.md` says what is adopted. Page numbers are the PDF's.

## Architecture

| Page | Figure | What it shows | Used in |
| ---- | ------ | ------------- | ------- |
| 4 | Four planes | Specification (contracts, topology, pipelines, policies, deployment definitions), control (discovery, routing, deployment, health), data (services A, B, C in a pipeline carrying domain transactions and synthetic heartbeats) and observation (logs, metrics, traces, replay, dashboards). Arrows run down from plane to plane, control and data both ways, and a dashed edge returns from observation to control: observations feed the decisions. | plan M2, docs/architecture.md |
| 10 | Functional core | A Rust runtime (network I/O, serialization, concurrency above; persistence, messaging, telemetry below) around an X_eTaL core: input + state -> output + effects, deterministic. | plan M2 |
| 20 | Control loop | Observe -> Analyze -> Decide -> Act -> Observe, around an X_eTaL policy engine (MAPE-K). | plan saga 8 |
| 24 | Execution backends | One X_eTaL specification (the same services, contracts and policies) runs on simulation (virtual clock), local (real processes) or distributed (multiple hosts), each with A, B, C. | plan M7 |
| 48 | Two levels | A distributed application of microservices A and B, each an FBP subnetwork of components with its own private state; component 2 of A sends to component 2 of B over service-to-service message transport. FBP composes inside a service, Richardson's patterns govern between services. | plan M8 |
| 61, 64 | Repository layers | X_eTaL-microservices over X_eTaL-FBP over X_eTaL-libraries and X_eTaL-extensions over X_eTaL core. On page 64 a dashed edge runs from microservices straight to extensions: "Microservices can also use runtime extensions directly. FBP never depends on microservices." | plan M1 |
| 69 | Two schedules | A Gantt chart over phases P1 to P6: FBP's research, core semantics, simulator, components, visualization; microservices' research and contracts start beside FBP's first phases (P1 to P2), the distributed runtime after FBP's simulator (P3), service patterns P4 to P5, operations P5 to P6. | plan, sagas |

## Topology

| Page | Figure | What it shows | Used in |
| ---- | ------ | ------------- | ------- |
| 6 | Order processing | Order Gateway -> Validation, fan-out to Inventory and Pricing, fan-in to Join Results -> Fulfillment. | Topology fixture |
| 8 | Dependency matrix | The same six services as an adjacency matrix, rows sources and columns destinations: GW -> VAL; VAL -> INV, PRICE; INV -> JOIN; PRICE -> JOIN; JOIN -> FULL (six ones). | Topology fixture |
| 40 | Bounded connection | Process A (ports OUT, ERR) and process B (IN, CTRL) joined by a connection of 5 slots, 3 occupied; "components do not name their neighbors". | X_eTaL-FBP's (not here) |
| 50, 51 | Sagas | Choreography: Orders, Inventory and Payments each emit to domain event streams (OrderCreated, StockReserved, PaymentFailed). Orchestration: a saga orchestrator, an X_eTaL state machine, commands Orders, Inventory and Payments. | plan saga 3 |
| 71 | Service Deployment Explorer | Gateway (service A) -> version routing (A/B, canary, rollback) -> Stable v1 and Candidate v2 (both service B) -> Collector (service C). Beside it FBP's first explorer: Generate -> Transform -> Filter -> Collect. | plan step poc, saga 6 |

## Charts with numbers

| Page | Figure | The numbers | Used in |
| ---- | ------ | ----------- | ------- |
| 12, 13 | Progressive deployment simulator | 1,000 tx/s in; 20% to the candidate; candidate error rate 0.8%; roll back above 2%. Stable v1 800 tx/s, candidate v2 200 tx/s; "estimated candidate errors/sec 1.60"; total executions 1,000/s; state Healthy. In shadow mode the total would be 1,200 (the candidate runs beside, not instead). | Rollout fixture |
| 14, 15 | Weighted least-cost load balancing | Instances A to E: healthy yes, yes, no, yes, yes; CPU 32, 68, 10, 41, 85 %; queue 4, 14, 0, 2, 19; latency 12, 28, -, 8, 42 ms; active 8, 24, 0, 6, 32. Weights CPU 25, queue 35, latency 40. Costs D 0.201, A 0.246, B 0.639, E 0.881; C excluded, unhealthy; selected D. The chart does not say how it normalizes; CPU / 100, queue / 20 and latency / 50 with the weights as fractions reproduce all four costs (D is 0.2015, shown cut to 0.201). | Balance fixture |
| 18 | Transaction trace | TX-10482, 182 ms: Gateway spans about 0 to 182 ms; Validate about 8 to 20; Inventory and Pricing v2 in parallel from about 25 (Inventory to about 70, Pricing to about 55); Join about 75 to 82; Persist about 92 to 160, the bottleneck on the critical path. Bars read from the chart, so approximate. | plan saga 4 |
| 46, 47 | Bounded buffer | Producer 12 IP/s, consumer 8 IP/s, capacity 16, backpressure: occupancy 4, 8, 12, then 16 from second 4 to 12; 32 offered packets not admitted; final utilization 100%. | X_eTaL-FBP's (not here) |

The bounded buffer and the bounded connection are FBP's abstractions
(plan M3): they are listed for completeness and asked of X_eTaL-FBP,
not built here.
