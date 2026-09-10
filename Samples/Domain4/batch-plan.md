# Scaling Pattern — Synchronous vs Batch

## Choose synchronous processing when

- the caller needs an immediate answer;
- the result blocks a pre-merge or customer-facing workflow;
- latency is part of the product experience;
- the operation has a tight response-time requirement.

## Choose Batch when

- work is bulk, overnight, weekly, or otherwise latency-tolerant;
- the workload can wait for asynchronous completion;
- lower token cost is more important than immediate completion.

Batch processing is not a drop-in replacement for a latency-sensitive synchronous path.

## Safe rollout

```text
Sample 100–500 items
       ↓
Measure quality / failures / cost
       ↓
Tune prompt + schema + validator
       ↓
Submit full batch
       ↓
Correlate with custom_id
       ↓
Retry only failed items
       ↓
Escalate persistent failures
```

Use a stable `custom_id` for every request so results can be correlated with source records and failed requests can be retried selectively.

## Hybrid architecture

```text
                 ┌─ real-time / blocking ──→ Sync API
Incoming work ───┤
                 └─ bulk / latency tolerant → Batch API
```

For mixed SLAs, route each workload according to its latency requirement rather than forcing everything through one API mode.
