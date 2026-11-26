# Topology

A service topology as data: dependency cycles, what an outage takes
down, the order to deploy in, services nothing reaches, redundant
routes, and when each service of a pipeline finishes, with its
critical path. Built on X_eTaL-libraries' Graphs.

```
"tp:" u_se< "Topology"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Topology.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples |
| [`demos/`](demos/) | `orders.xtl`: the research's order-processing system, its outages, deployment waves and critical path |
| [`tests/`](tests/) | reg-rs baselines: `order.xtl` (14 checks on the order-processing topology), `panic-cycle.xtl`, the pinned export types (`types.rgt`) and the demo (`demo-orders.rgt`) |

```bash
just demo Topology       # run its demo
just run-lib Topology    # run its test programs
just test Topology       # check every baseline
```
