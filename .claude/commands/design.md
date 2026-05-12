# /design

Analyze a system design problem and produce a structured architecture recommendation.

## Input
Describe the system to design: scale, constraints, SLA requirements, team size, existing stack.

## Analysis Steps

### 1. Requirements Clarification
Before designing, explicitly state assumptions about:
- **Scale**: DAU, RPS (read/write ratio), data volume, geographic distribution
- **SLA**: availability target (99.9% = 8.7h/year downtime), latency P99 target
- **Consistency**: strong vs eventual, which data requires which
- **Team**: size, existing expertise, operational capacity

### 2. Architecture Selection (use decision matrix from CLAUDE.md)
State the chosen pattern and why. Explicitly state what was rejected and why.

### 3. Component Design
For each component produce:
```
[Component Name]
  Purpose: what it does
  Technology: what to use and why
  Scaling: how it scales, bottlenecks
  Failure mode: what breaks and how to recover
  Interfaces: APIs/events it exposes
```

### 4. Data Flow Diagram (text)
```
Client → API Gateway → [Service A] → DB (primary)
                    ↘ [Service B] → Cache → DB (read replica)
                                 → Queue → [Worker]
```

### 5. Failure Analysis
For each external dependency, answer:
- What happens when it fails?
- Is there a circuit breaker?
- Is there a fallback?
- What is the blast radius?

### 6. Capacity Estimate
```
RPS: X  ×  avg_payload: Y KB  =  bandwidth: Z MB/s
Storage: N events/day × avg_size × retention_days = X GB/month
DB connections: services × instances × pool_size = peak connections
```

### 7. Open Questions
List unresolved decisions that require product/business input before finalizing.

## Output Format
Structured sections above + a one-paragraph summary of the highest-risk decision in the design.
