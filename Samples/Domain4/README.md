# CCA-F Domain 4 — Prompt Engineering & Structured Output Sample

A reference implementation for Domain 4: **Prompt Engineering & Structured Output**.

This sample consolidates the Domain 4 study material with the additional Gemini-prepared notes supplied for this project. Where the supplied notes use different numeric guidance, this repository favors the exam-oriented ranges already established in the CCA-F study material (for example, a small set of 2–4 few-shot examples and a bounded 2–3 retry budget) rather than treating one number as a universal production rule.

## Learning objectives

This sample demonstrates the complete production-oriented workflow:

```text
SPECIFY → DEMONSTRATE → CONSTRAIN → GENERATE → VALIDATE
                                           ↓
                                  PASS / FAIL
                                           ↓
                                  specific retry
                                           ↓
                                      escalate
```

It deliberately demonstrates both best practices and common pitfalls.

## What this sample covers

### Prompt engineering

1. Explicit, measurable review criteria
2. Colleague-testable decision boundaries
3. Categorical `REPORT` / `SKIP` decisions to control false positives
4. Severity definitions
5. Semantic XML tagging for prompt boundaries
6. System-prompt role/behavior boundaries
7. Few-shot examples focused on difficult boundary cases
8. Never-fabricate handling of missing information
9. Extended thinking as a reasoning aid, not a substitute for validation

### Structured output

10. Structured output with `tool_use` / JSON Schema
11. `tool_choice`: `auto`, `any`, and forced named-tool selection
12. Schema design: `required`, nullable fields, enums, `other`/`unclear` escape hatches
13. `additionalProperties: false` to reject schema drift
14. Structural validity versus semantic/business correctness

### Reliability

15. Deterministic application validation
16. Specific validation feedback
17. Bounded retry loops
18. Human-review escalation
19. Confidence as a routing signal rather than proof of correctness

### Scale and review

20. Partitioning large outputs/contexts
21. Synchronous versus Message Batches API
22. Sample-before-full-batch rollout
23. `custom_id` correlation and targeted retry
24. Independent review instances
25. Multi-pass local + integration review
26. Merge/deduplication of findings

## Files

- `README.md` — this overview and Domain 4 checklist
- `prompt.md` — production-style prompt, XML structure, examples, schema guidance, and anti-patterns
- `schema.json` — constrained output schema
- `sample-input.json` — representative payment-review input
- `sample-output.valid.json` — structurally and semantically valid result
- `sample-output.invalid.json` — intentionally invalid result for validation/retry exercises
- `validation.md` — structural validation, semantic validation, retry strategy, and escalation
- `batch-plan.md` — synchronous/Batch decision and safe rollout pattern
- `review-architecture.md` — independent-instance, partitioning, and multi-pass review design

## Recommended study sequence

```text
1. Read prompt.md
       ↓
2. Inspect schema.json
       ↓
3. Compare valid vs invalid output
       ↓
4. Apply validation.md
       ↓
5. Design a specific retry message
       ↓
6. Decide Sync vs Batch using batch-plan.md
       ↓
7. Design local + integration review using review-architecture.md
```

## Core exam mental model

> **Specify → Demonstrate → Constrain → Validate → Correct → Scale → Review**

The key distinction is that structured output constrains the **shape** of an answer; it does not prove that the answer is **semantically correct**. Deterministic application validation remains necessary.

## Common exam traps represented here

| Trap | Better architectural choice |
|---|---|
| “Be accurate / be conservative” | Explicit categorical criteria |
| Report everything suspicious | Define both REPORT and SKIP boundaries |
| Only easy few-shot examples | Demonstrate boundary/edge cases |
| “Output JSON only” | Schema-backed structured output |
| Force every field to be required | Required only when genuinely required; nullable when legitimately absent |
| Closed enum with no escape hatch | `other`/`unclear` + detail field when taxonomy is incomplete |
| Trust schema as proof of correctness | Run semantic/business validation |
| “Try again” | Specific field/value/error/expected correction |
| Unlimited retries | Bounded retries + escalation |
| Batch for blocking CI/user flows | Synchronous processing |
| One giant review prompt | Partition + local analysis + integration synthesis |
| Same-instance self-review | Fresh independent reviewer when independence matters |
| High self-reported confidence = truth | Confidence only helps route work |
