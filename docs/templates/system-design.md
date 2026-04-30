---
doc_type: system-design
version: 1
status: draft
created: YYYY-MM-DD
revised: YYYY-MM-DD
revision: 1
---
# System Design: [Project Name]

## Architecture Overview

[High-level description of the system architecture. Include a diagram or ASCII art if helpful.]

## Components

### [Component Name]

**Responsibility**: [What this component does]
**Technology**: [Language, framework, or runtime]
**Interfaces**: [APIs, protocols, or file formats it exposes]

## Technology Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| [Layer] | [Technology] | [Why this was chosen] |

## Integration Points

| System | Direction | Protocol | Notes |
|--------|-----------|----------|-------|
| [External system] | inbound/outbound | [HTTP/gRPC/etc] | [Auth, rate limits, etc] |

## Non-Functional Requirements

- **Performance**: [Latency, throughput targets]
- **Security**: [Auth model, data sensitivity]
- **Reliability**: [Uptime, fault tolerance]
- **Observability**: [Logging, metrics, tracing]

## Open Questions

- [ ] [Architectural decision pending human input]
