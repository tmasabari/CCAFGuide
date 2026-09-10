# Scaling Pattern — Synchronous vs Message Batches API

## Decision rule

Choose the execution path from the latency requirement first, then optimize cost.

### Synchronous Messages API

Use synchronous processing when:

- the caller needs an immediate answer;
- the result blocks a pre-merge/CI gate;
- the result is customer-facing;
- the workflow needs interactive multi-turn execution.

### Message Batches API

Use Batch when:

- work is bulk, overnight, weekly, or otherwise latency-tolerant;
- asynchronous completion is acceptable;
- lower token cost is more important than immediate completion.

The study material describes Batch as roughly 50% cheaper per token and allowing processing over an asynchronous window of up to 24 hours. Treat those properties as workload-planning characteristics, not as a promise of an exact completion time.

Batch is not a drop-in replacement for a latency-sensitive synchronous path.

## Important execution constraint

Design the batch item as an independent request. Do not assume an interactive multi-turn tool loop can be carried out inside a single batch item. If a workflow fundamentally requires interactive turns, use the synchronous path or orchestrate the turns outside the batch boundary where supported.

## Safe rollout

```text
Sample 100–500 items synchronously
              ↓
Measure quality / failures / cost
              ↓
Tune prompt + examples + schema + validator
              ↓
Submit full batch
              ↓
Correlate each result with custom_id
              ↓
Validate each result
              ↓
Retry only failed custom_ids
              ↓
Escalate persistent failures
```

Use a stable `custom_id` for every request so results can be correlated with source records and failed requests can be retried selectively.

## Hybrid architecture

```text
                         ┌─ real-time / blocking ──→ Sync API
Incoming workload ───────┤
                         └─ bulk / latency tolerant → Batch API
```

For mixed SLAs, route each workload according to its latency requirement rather than forcing everything through one API mode.
