# Architecture Decision Records (ADR)

## ADR-001: Producer-Consumer Pattern
**Context:** Need to decouple device I/O from consumers
**Decision:** Use separate threads with blocking queue
**Alternatives Considered:** Event loop, callbacks, async/await
**Rationale:** [explain why this was best]
**Consequences:** [trade-offs, limitations]

## ADR-002: Bounded Queue with Drop-Oldest
**Context:** Real-time telemetry where latest data matters most
**Decision:** Bounded queue, drop oldest when full
**Alternatives:** Drop-newest, backpressure, dynamic sizing
**Rationale:** [performance vs memory trade-off]