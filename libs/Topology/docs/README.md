# Topology

A service topology as data: which services are on a dependency cycle,
what a failed service takes with it, the order to deploy in, services
no entry reaches, how many routes join two services, and when each
service of a pipeline finishes, with its critical path.

```
"tp:" u_se< "Topology"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `tp:` is the
recommended alias.

A topology of `n` services, numbered 1 to `n`, is an `n` by `n`
matrix `m`: item `i j` is 1 when service `i` sends to (calls, or
feeds) service `j`, as X_eTaL-libraries' Graphs builds it
(`n g:a_djacency edges`). Topology adds what a service topology asks
of such a graph; degrees, distances and components are Graphs' own
(`g:o_utDegree`, `g:i_nDegree`, `g:s_hortest`, `g:c_omponents`).

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `tp:c_ycles m` | `(Num a, Num b, Truthy b) => a -> b` | 1 for each service on a dependency cycle |
| `tp:a_cyclic? m` | `(Num a, Truthy b) => a -> b` | 1 when no service is on a cycle |
| `m tp:u_pstream s` | `(Num a, Num b, Truthy b) => a -> Int -> b` | 1 for each service that depends on `s`, by one or more edges |
| `m tp:d_ownstream s` | `(Num a, Num b, Truthy b) => a -> Int -> b` | 1 for each service `s` depends on, by one or more edges |
| `m tp:b_last s` | `(Num a, Num b, Truthy b) => a -> Int -> b` | the blast radius of `s` failing: `s` and every service on a path through it |
| `tp:l_evels m` | `Num a => a -> a` | each service's deployment level: 0 for one that depends on nothing, else one above the highest it depends on; a panic on a cycle, naming its services |
| `m tp:o_rphans entries` | `(Num a, Num b, Truthy b) => a -> Int -> b` | 1 for each service that is not an entry and that no entry reaches |
| `tp:p_aths m` | `Num a => a -> a` | item `i j` is the number of routes from `i` to `j` (acyclic topologies) |
| `m tp:f_inish lat` | `Num a => a -> a -> a` | when each service of a pipeline finishes: it starts when the last service feeding it has finished and takes its latency `lat` (acyclic) |
| `m tp:c_ritical lat` | `Num a => a -> a -> Int` | the critical path, entry first: the services whose latencies make up the last finish time |

## Semantics

- Upstream is "who depends on me" (follow edges backward), downstream
  "what I depend on" (forward). The blast radius takes both, because
  in a pipeline a failed service starves what it feeds and fails what
  feeds it; a service on a parallel branch (pricing, when inventory
  fails) is spared.
- `tp:l_evels` is the deployment order of the research's page 8
  analysis: deploying level 0 first, then 1, never starts a service
  before what it depends on. A cycle has no such order.
- `tp:f_inish` is dataflow timing: a join waits for all its inputs, a
  fan-out runs its branches side by side. `tp:c_ritical` follows, back
  from the last service to finish, the input that finished last.

## Examples

From `../tests/order.xtl`, the research's order-processing topology
(gateway 1, validate 2, inventory 3, pricing 4, join 5, fulfill 6):

```
      m := 6 g:a_djacency 2 6 r_eshape 1 2 2 3 4 5  2 3 4 5 5 6
      tp:l_evels m
4 3 2 2 1 0
      m tp:b_last 3
1 1 1 0 1 1
      6 s_elect 1 s_elect tp:p_aths m
2
      m tp:f_inish 8 12 45 30 7 68
8 20 65 50 72 140
      m tp:c_ritical 8 12 45 30 7 68
1 2 3 5 6
```

`../demos/orders.xtl` prints the same by name: each outage's blast
radius, the deployment waves (fulfill, join, inventory and pricing,
validate, gateway) and the critical path, gateway -> validate ->
inventory -> join -> fulfill.

## Notes

- Services are numbered; a demo names them with one variable per
  service and joins the edges with `c_at`, because variables do not
  form strands. A directed `g_raph<` (asked of X_eTaL-libraries, L1)
  would write those definitions from a text such as
  `"gateway-validate-inventory-join-fulfill, validate-pricing-join"`.
- Path counts and finish times assume no cycle: check `tp:a_cyclic?`
  first.
