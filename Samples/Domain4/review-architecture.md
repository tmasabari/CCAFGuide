# Review Architecture — Independent Instance + Multi-Pass

## Why not rely on same-instance self-review?

A model that generated a result and then evaluates its own result can share the same reasoning blind spots and confirmation bias. A fresh independent reviewer provides a stronger independence boundary.

## Multi-instance review

```text
                         ┌→ Reviewer A ─┐
Source / result ─────────┼→ Reviewer B ─┼→ aggregate → dedupe → final review
                         └→ Reviewer C ─┘
```

Use independent instances/prompts when catching correlated errors is important. Aggregate findings and deduplicate overlapping reports.

## Multi-pass review

Different passes focus attention on different concerns and reduce attention dilution:

```text
Large change set
      ↓
Pass 1: isolated local analysis
      ↓
Pass 2: cross-file integration / synthesis
      ↓
Pass 3: optional verification / triage
      ↓
merge + dedupe + route
```

A useful concrete implementation is:

```text
Pass 1
├── File A → local correctness/security/reliability
├── File B → local correctness/security/reliability
└── File C → local correctness/security/reliability
             ↓
Pass 2
└── Synthesis → interfaces + end-to-end data flow + cross-file side effects
             ↓
Pass 3 (optional)
└── Independent verifier → challenge important findings
```

Multi-pass review addresses **attention/scope**; multi-instance review addresses **reviewer independence**. They solve different problems and can be combined.

## Large workloads

Partition large inputs rather than forcing one enormous prompt/output:

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

## Incremental reviews

When reviewing later pull requests, previous findings can be supplied as comparison context so the reviewer focuses on unaddressed or novel issues. Do not blindly suppress a finding solely because it resembles an older one; validate that it is actually resolved.

## Confidence

Confidence is a **routing signal**, not a truth filter. For example, low-confidence or ambiguous findings can be sent to human review. A high self-reported confidence score is not a substitute for evidence or deterministic validation.
