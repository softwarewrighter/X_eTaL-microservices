# Asks for X_eTaL-FBP

What this repository needs from X_eTaL-FBP, the flow-based programming
foundation it builds on (docs/plan.md, M1, M3 b). X_eTaL-FBP owns
information packets, named ports, connections, bounded buffers,
backpressure, scheduling, subnetworks, network definitions and
substreams; this repository never writes its own version of any of
them. It asks here instead, and until an ask lands it works at the
level of whole transactions and service calls. X_eTaL-FBP never depends
on this repository.

Each entry: status (open, filed, landed, dropped), kind (feature, bug
or interface), who here needs it, why, a minimal example, and the
workaround in use.

| Status | Kind | Ask | Needed by | Workaround |
| ------ | ---- | --- | --------- | ---------- |
| open | interface | A first library to pin: at 1ebd5bf (2026-11-24) X_eTaL-FBP holds only its research, so there is nothing to put in `XETAL_FBP_COMMIT` yet | saga 5 (the FBP partitioning), the proof of concept's re-hosting | programs here model service calls, not ports and packets |
