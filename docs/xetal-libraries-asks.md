# Asks for X_eTaL-libraries

General functions (graphs, statistics, hashing, text) that libraries here would otherwise have to write and that a repository with no interest in microservices would want (plan M3, c). This repository does not change X_eTaL-libraries: each ask is filed here (and
taken to `../X_eTaL-libraries`), the program here uses the workaround noted or
waits, and the workaround is removed when the ask lands at the pin
this repository uses (docs/plan.md, M1, M3).

Each entry: status (open, filed, landed, dropped), kind (feature, bug
or interface), who here needs it, why, a minimal example, and the
workaround in use.

| Status | Kind | Ask | Needed by | Workaround |
| ------ | ---- | --- | --------- | ---------- |
| open | feature | L1. A directed `g_raph<` in Graphs: at c7e812e `"town" g:g_raph< "a-b-c"` defines a variable per station and an adjacency matrix with every edge both ways. A service topology is directed (who calls whom), so the same macro with directed paths (for instance `"order" g:d_igraph< "gateway>validate>inventory>join, validate>pricing>join"`) would name the services and build the matrix in one statement. General: any directed graph written by names wants it | Topology's demo, every topology demo to come | one variable per service and the edges joined with `c_at` (`libs/Topology/demos/orders.xtl`) |
