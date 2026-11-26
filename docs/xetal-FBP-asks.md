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
| open | interface | Packet metadata beside the payload: an information packet carries, or can be paired with, a small fixed set of envelope fields (trace id, class, deadline, idempotency key) that every component passes on unchanged unless it means to change them, so that a trace and the heartbeat class survive a network and a service boundary (docs/architecture.md, "The envelope") | Envelope, Health, Trace; the effect guard | the envelope travels as the transaction itself, at the service level |
| open | interface | The network as data: processes, ports and connections readable as tables (process, component; connection: from process, from port, to process, to port, capacity, overflow policy), so this repository can partition a network into services (`d_eploy<`, research page 53), check contracts across a boundary and analyze it with Topology. A network written with a macro should expand to these tables | saga 5, Topology | Topology's own edge table of services |
| open | interface | Port contracts as data: each port's direction and payload type (or a contract name) queryable, so a consumer-driven contract check can compare two services' ports | Envelope (contract tests), saga 5 | contracts named by schema version in the envelope |
| open | interface | A connection's placement left open: a component never knows whether a connection is local or remote; the network table may mark a connection's transport (local, then remote) without the components changing | saga 5, saga 7 | not needed while everything is one process |
| open | interface | A deterministic, seeded scheduler on virtual time (integer ticks), the same inputs giving the same run, with a hook per delivery (a tap) so a wire tap, a journal and a fault injector can be components or hooks rather than changes to the scheduler | the proof of concept's re-hosting, Trace, fault injection (saga 2) | this repository's simulations step whole transactions with `p_ower` |
| open | interface | Typed outcomes on a connection to a remote process: a send can end ok, rejected, transport failure, timeout or unknown (docs/architecture.md, "Failure semantics"), as a value, not a panic; inside one process only ok occurs | saga 5, saga 7 | outcomes are Envelope's codes, produced by the simulation |
| open | interface | Overflow policies as data on a connection (block the producer, the default; drop oldest; drop newest; reject; persist; reroute), the research's page 47 numbers (12 in, 8 out, capacity 16: occupancy 4, 8, 12, 16 ..., 32 not admitted over 12 seconds) as a test | Resilience (load shedding), saga 5 | none here: backpressure is not modeled at the service level yet |
