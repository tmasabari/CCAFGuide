# CCA-F Domain 4 — Prompt Engineering & Structured Output Sample

A reference implementation for Domain 4: Prompt Engineering & Structured Output.

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

1. Explicit, measurable review criteria
2. Categorical `REPORT` / `SKIP` decisions to control false positives
3. Few-shot examples focused on boundary cases
4. Structured output with `tool_use` / JSON Schema
5. Schema design: `required`, nullable fields, enums, `other` escape hatches
6. `additionalProperties: false` to prevent schema drift
7. Structural validation versus semantic/business validation
8. Specific validation feedback and bounded retry loops
9. Partitioning for large outputs
10. Synchronous versus Batch processing decisions
11. Independent review instances and multi-pass review
12. Confidence as a routing signal rather than a truth filter

## Files

- `prompt.md` — production-style prompt, examples, and anti-patterns
- `schema.json` — constrained output schema
- `sample-input.json` — representative source input
- `sample-output.valid.json` — structurally and semantically valid result
- `sample-output.invalid.json` — intentionally invalid result for validation/retry exercises
- `validation.md` — validation rules, retry strategy, and escalation
- `batch-plan.md` — scaling the same workflow with synchronous/Batch processing
- `review-architecture.md` — independent-instance and multi-pass review design

## Core exam mental model

> **Specify → Demonstrate → Constrain → Validate → Correct → Scale → Review**

The key distinction is that structured output guarantees the **shape** of an answer, not that the answer is **semantically correct**. Business validation remains necessary.
