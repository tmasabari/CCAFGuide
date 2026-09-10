# Review Architecture — Independent Instance + Multi-Pass

## Why not rely on same-instance self-review?

A model that generated a result and then evaluates its own result can share the same reasoning blind spots. A fresh independent reviewer provides a stronger independence boundary.

## Multi-instance review

```text
                 ┌→ Reviewer A ─┐
Source / result ─┼→ Reviewer B ─┼→ aggregate / dedupe → final review
                 └→ Reviewer C ─┘
```

Use independent instances/prompts when catching correlated errors is important. Aggregate findings and deduplicate overlapping reports.

## Multi-pass review

Different passes focus attention on different concerns:

```text
Change
  ↓
Pass 1: security
  ↓
Pass 2: correctness
  ↓
Pass 3: reliability
  ↓
Pass 4: integration / consistency
  ↓
merge + dedupe
```

Multi-pass review addresses attention dilution; multi-instance review addresses reviewer independence. They solve different problems and can be combined.

## Large workloads

Partition large inputs rather than forcing one enormous output:

```text
Large change set
      ↓
 partition / shard
 ┌────┼────┐
 ↓    ↓    ↓
P1   P2   P3
 │    │    │
 └────┼────┘
      ↓
 merge + dedupe
      ↓
 cross-file integration pass
```

Keep enough context in each partition to make local decisions reliable, then perform a cross-partition integration pass for consistency.

## Confidence

Confidence is a routing signal. For example, low-confidence or ambiguous findings can be sent to human review. Do not use a high self-reported confidence score as a substitute for evidence or validation.
