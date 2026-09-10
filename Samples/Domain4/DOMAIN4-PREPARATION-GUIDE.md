# CCA-F Domain 4 Preparation Guide

> **Prompt Engineering & Structured Output**
>
> Exam focus: designing reliable prompt systems, enforcing structured outputs, validating model results, recovering from failures, choosing synchronous vs Batch processing, and designing scalable review architectures.

---

## 1. Domain 4 at a glance

The central idea of Domain 4 is that a production LLM system should not depend on a single clever prompt. Reliability comes from a pipeline:

```text
┌──────────────┐
│  1. SPECIFY  │  Explicit criteria + boundaries
└──────┬───────┘
       ↓
┌──────────────┐
│ 2. DEMONSTRATE│ Few-shot examples + edge cases
└──────┬───────┘
       ↓
┌──────────────┐
│ 3. CONSTRAIN │  Tool/schema/structured output
└──────┬───────┘
       ↓
┌──────────────┐
│  4. GENERATE  │  Claude produces the result
└──────┬───────┘
       ↓
┌──────────────┐
│  5. VALIDATE │  Structure + semantics + business rules
└──────┬───────┘
       │
   ┌───┴────┐
   │        │
 PASS     FAIL
   │        ↓
   │   Specific feedback
   │        ↓
   │      retry
   │        ↓
   │   bounded attempts
   │        ↓
   │     escalation
   ↓
 ACCEPT

Scale → synchronous / Batch / partitioning
Quality → independent review / multi-pass / integration review
```

### Master mental model

> **SPECIFY → DEMONSTRATE → CONSTRAIN → VALIDATE → CORRECT → SCALE → REVIEW**

---

# 2. Explicit review criteria

## 2.1 Why vague instructions fail

Instructions such as:

- “Be accurate.”
- “Be conservative.”
- “Review carefully.”
- “Find important issues.”
- “Report high-confidence findings.”

leave the decision boundary to the model. Different inputs can therefore produce inconsistent classifications and excessive false positives.

### Better pattern

Define categorical, measurable rules.

```text
                REVIEW INPUT
                     │
          ┌──────────┴──────────┐
          ↓                     ↓
       REPORT                  SKIP
          │                     │
   Concrete evidence?      Style preference?
   Concrete impact?        Insufficient evidence?
   Actionable?             Speculation?
          │                     │
          └───────┬─────────────┘
                  ↓
            deterministic
             decision rule
```

### Colleague Test

Ask:

> Could an intelligent human contractor execute the instruction without asking for clarification?

If not, make the criteria more explicit.

## 2.2 False positives are an architecture problem

Noisy automated review causes alert fatigue. Developers begin ignoring the system, so even genuinely important findings lose trust.

Therefore optimize for **useful precision**, not simply the maximum number of findings.

### Include both positive and negative criteria

```text
REPORT when:
  evidence exists
  AND concrete impact exists
  AND actionable
  AND within supported categories

SKIP when:
  style-only
  OR insufficient evidence
  OR speculative
  OR outside scope
```

## 2.3 Severity definitions

Define severity explicitly. For example:

- **critical** — exploitable security issue, data loss, or severe production failure.
- **high** — likely production failure or serious security/reliability/correctness problem.
- **medium** — meaningful defect with limited scope or realistic operational risk.
- **low** — minor but concrete actionable issue; not subjective style feedback.

Do not leave “high severity” to intuition.

## 2.4 Never fabricate

Explicitly tell the model:

- Do not invent files.
- Do not invent APIs.
- Do not invent runtime behavior.
- Do not invent tests or test results.
- Do not invent missing source data.
- If evidence is insufficient, skip or use an explicit `unclear`/nullable representation where appropriate.

---

# 3. Few-shot prompting

## 3.1 Why examples matter

Detailed prose can describe a rule, but examples demonstrate the actual decision boundary.

Use examples to show:

- what should be reported;
- what should be skipped;
- severity boundaries;
- ambiguous cases;
- missing-data behavior;
- expected output shape.

### Recommended pattern

```text
<examples>
  <example>
    <input>...</input>
    <output>...</output>
    <rationale>...</rationale>
  </example>
  ...
</examples>
```

The consolidated study material recommends a small set of diverse examples; use **2–4 strong examples** as the core exam heuristic, while recognizing that the exact number can vary with task complexity.

## 3.2 Choose examples strategically

Do not spend all examples on easy cases.

Prefer:

```text
Example 1 → clear REPORT
Example 2 → clear SKIP
Example 3 → difficult boundary case
Example 4 → missing/ambiguous information
```

The most valuable example is often the one where a capable model could reasonably make the wrong decision.

## 3.3 Demonstrate the rationale

When useful, show **why** the example is reported or skipped. This teaches the decision boundary instead of merely teaching output tokens.

---

# 4. Prompt structure and semantic boundaries

Use clear structural separation for complex prompts.

```text
<instructions>
  What the model must do
</instructions>

<rules>
  Decision criteria and constraints
</rules>

<context>
  Trusted task context
</context>

<document>
  Untrusted/source material
</document>

<examples>
  Boundary demonstrations
</examples>
```

The important architectural principle is **clear separation of instructions from data**. XML-style tags are a useful convention; they are not a substitute for schema validation or application-level security controls.

Use the system prompt for stable behavioral constraints and task identity. Keep variable task data in the appropriate context/user content.

---

# 5. Structured output

## 5.1 Do not rely on “return JSON only”

Natural-language instructions can still result in:

- markdown fences;
- explanatory prose;
- missing fields;
- wrong types;
- invalid enum values;
- additional fields.

For production extraction, constrain the output with a typed schema.

## 5.2 Tool-based structured output

A common Domain 4 pattern is to define the desired output as a tool contract:

```text
Claude
  │
  │ tool_use
  ↓
Target tool
  │
  └── input_schema / JSON Schema
             │
             ↓
       typed structure
```

### tool_choice modes

Conceptually distinguish:

- `auto` — Claude decides whether to use a tool.
- `any` — Claude must call at least one supplied tool.
- forced named tool — Claude must invoke the specified tool.

Use the least restrictive mode that satisfies the workflow. If structured extraction is mandatory and there is a single target schema, forcing the target tool removes conversational fallback.

## 5.3 Structured output is not semantic validation

This is a critical exam distinction:

```text
JSON Schema
    ↓
shape / types / enum / requiredness

        ≠

semantic validation
    ↓
factual correctness / business rules / cross-field consistency
```

A schema can prove that `amount` is a number. It cannot prove that the amount is correct.

---

# 6. Schema design as a hallucination-control mechanism

Schema design does more than describe data. It constrains the model's available answer space.

## 6.1 Required fields

Use `required` when the source or workflow guarantees that the value must exist.

### Pitfall

Making every field required can pressure the model to fabricate values.

```text
Source does not contain value
          ↓
Field is required
          ↓
Model feels pressure to fill it
          ↓
Hallucinated value
```

## 6.2 Nullable fields

If a value can legitimately be absent, permit `null`.

```json
{
  "middle_name": null
}
```

This gives the model a truthful representation for missing information.

## 6.3 Enums

Use enums for controlled vocabularies.

```json
{
  "severity": {
    "type": "string",
    "enum": ["critical", "high", "medium", "low"]
  }
}
```

## 6.4 The `other` / `unclear` escape hatch

Closed taxonomies can become brittle when the real world contains a value not anticipated by the schema.

Prefer:

```json
{
  "category": "other",
  "category_detail": "unanticipated category"
}
```

or:

```json
{
  "category": "unclear",
  "category_detail": "source evidence is insufficient"
}
```

This is safer than forcing an incorrect known category.

## 6.5 additionalProperties

Where a closed contract is intended, use:

```json
"additionalProperties": false
```

This exposes schema drift rather than silently accepting unexpected output fields.

## 6.6 Conditional requirements

Requirements can depend on the decision.

Example:

```text
REPORT → evidence required
SKIP   → finding/evidence may be null
```

This is better than making fields universally required when they do not apply to every outcome.

---

# 7. Validation architecture

Never assume tool/schema enforcement makes the result correct.

## 7.1 Three validation layers

```text
Model output
    │
    ↓
┌──────────────────────┐
│ 1. Structural        │
│ schema / type checks  │
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│ 2. Semantic          │
│ meaning / evidence   │
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│ 3. Business / system │
│ invariants / state   │
└──────────┬───────────┘
           ↓
        ACCEPT
```

### Structural checks

Examples:

- required fields present;
- correct types;
- enum values allowed;
- no unexpected properties;
- valid ranges.

### Semantic checks

Examples:

- finding is supported by evidence;
- severity matches impact;
- summary accurately represents source;
- dates/relationships make sense.

### Business checks

Examples:

- totals reconcile;
- IDs exist in the database;
- state transitions are legal;
- external system confirms the requested operation.

---

# 8. Validation → specific retry → escalation

## 8.1 Generic retry is weak

Bad:

```text
Try again. The output is invalid.
```

This does not tell the model what new information it should use.

## 8.2 Specific retry feedback

Good:

```text
Field: severity
Produced value: urgent
Error: value is not in the allowed enum.
Expected values: critical, high, medium, low, null.
Correction: choose an allowed value based on the defined severity criteria.
```

For semantic errors:

```text
Field: evidence
Produced claim: duplicate charge is guaranteed
Problem: supplied source only establishes that a retry occurs;
         it does not establish that the provider actually duplicates charges.
Expected correction: limit the finding to evidence-supported behavior.
```

## 8.3 Retry architecture

```text
                 ┌───────────────┐
                 │ Generate      │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │ Validate      │
                 └───────┬───────┘
                         ↓
                  ┌──────┴──────┐
                  │             │
                PASS          FAIL
                  │             ↓
                  │      Specific error
                  │             ↓
                  │          Retry
                  │             ↓
                  │      retry budget
                  │             ↓
                  │       unresolved
                  │             ↓
                  │      human review
                  ↓
                ACCEPT
```

Use a **bounded retry budget**, typically around 2–3 attempts in this study pattern. Do not retry indefinitely.

## 8.4 When NOT to retry

If the source genuinely does not contain the requested information, retrying the same prompt does not create evidence.

```text
Missing evidence
      ↓
   null / unclear
      ↓
   accept or escalate
```

Retry when the failure is recoverable through correction. Escalate when the information is fundamentally unavailable, ambiguous with material consequences, or repeatedly invalid.

---

# 9. Synchronous Messages vs Message Batches API

## 9.1 Decision rule

```text
Does the caller need the result now?
          │
     ┌────┴────┐
    YES       NO
     │         │
   Sync      Batch
```

### Synchronous

Use for:

- interactive user requests;
- customer-facing responses;
- blocking CI/pre-merge gates;
- workflows with tight latency requirements;
- multi-turn conversational execution.

### Batch

Use for:

- overnight reports;
- weekly audits;
- bulk extraction;
- large offline analysis;
- latency-tolerant processing where lower token cost matters.

The consolidated material describes Batch as roughly **50% cheaper on token pricing** with asynchronous completion that can take up to **24 hours**. Do not interpret this as an exact completion-time guarantee for every job.

## 9.2 Batch workflow

```text
Sample workload
     ↓
Test synchronously
     ↓
Measure quality / failures / cost
     ↓
Tune prompt + schema + validator
     ↓
Submit full batch
     ↓
Correlate using custom_id
     ↓
Retry only failed requests
     ↓
Escalate persistent failures
```

## 9.3 custom_id

Give every batch request a stable correlation identifier.

```text
custom_id = source-record / logical-operation ID
```

This allows the application to map results back to source records and selectively retry failures.

## 9.4 Hybrid architecture

```text
                         ┌─ customer-facing ─→ Sync
Incoming work ───────────┤
                         └─ offline bulk ───→ Batch
```

Do not choose Batch merely because it is cheaper when latency is part of the requirement.

---

# 10. Large-output and large-context strategies

Increasing the output limit is not always the right solution to a large review.

Partition the work when one huge context would cause attention dilution or make validation and retry difficult.

```text
Large input
    ↓
partition / shard
 ┌──┼──┐
 ↓  ↓  ↓
P1 P2 P3
 │  │  │
 └──┼──┘
    ↓
merge + dedupe
    ↓
integration pass
```

### Partitioning rules

Each partition should contain enough local context to make reliable decisions. Then a later integration pass handles relationships that cross partition boundaries.

---

# 11. Multi-instance vs multi-pass review

These solve different problems.

## 11.1 Multi-instance review = independence

A model reviewing its own generated work in the same context can share the same blind spots.

```text
                 ┌→ Reviewer A ─┐
Source / result ─┼→ Reviewer B ─┼→ aggregate → dedupe
                 └→ Reviewer C ─┘
```

Use fresh independent sessions/instances when reviewer independence matters.

## 11.2 Multi-pass review = attention and scope

```text
Change
  ↓
Pass 1: local / security
  ↓
Pass 2: correctness
  ↓
Pass 3: reliability
  ↓
Pass 4: integration / consistency
  ↓
merge + dedupe
```

A simpler two-pass pattern for large codebases is:

```text
Pass 1: isolated per-file analysis
             ↓
Pass 2: cross-file integration synthesis
```

## 11.3 Combine both

For high-value workflows:

```text
partition
   ↓
independent local reviewers
   ↓
merge + dedupe
   ↓
cross-file integration pass
   ↓
independent verification
   ↓
human review where required
```

## 11.4 Confidence

Confidence is useful for **routing**, not for proving correctness.

```text
low confidence ─────→ human review
high confidence ────→ normal automated path
```

A model saying “confidence = 0.99” does not establish that a claim is true.

---

# 12. Domain 4 anti-pattern matrix

| Anti-pattern | Failure | Better architecture |
|---|---|---|
| “Be conservative” | Subjective decision boundary | Explicit categorical criteria |
| “Output JSON only” | Parse failures / prose leakage | Structured schema/tool contract |
| Every field required | Fabrication pressure | Required only when guaranteed; nullable otherwise |
| Closed enum only | Novel values forced into wrong category | `other` / `unclear` + detail |
| Generic retry | Same failure repeats | Specific field/value/error/correction |
| Infinite retry | Cost/latency runaway | Bounded retries + escalation |
| Schema-only validation | Semantically wrong data accepted | Structural + semantic + business validation |
| Batch for blocking workflow | SLA violation | Synchronous API |
| Batch everything | Cost optimization overrides latency | Route by SLA |
| Full batch without testing | Expensive systematic mistakes | Sample first, then batch |
| Retry entire failed batch | Wastes cost | Retry failed `custom_id`s only |
| One giant review prompt | Attention dilution | Partition + multi-pass |
| Same-session self-review | Shared blind spots | Fresh independent reviewer |
| Confidence as truth | False assurance | Confidence as routing signal |
| Style-only findings | Alert fatigue | Concrete actionable criteria |

---

# 13. Exam decision tree

When a scenario appears in the exam, reason in this order:

```text
START
  │
  ├─ Is the instruction vague?
  │       └─ YES → explicit criteria
  │
  ├─ Are boundary decisions inconsistent?
  │       └─ YES → few-shot examples
  │
  ├─ Is output machine-consumed?
  │       └─ YES → structured schema/tool
  │
  ├─ Can a value legitimately be absent?
  │       └─ YES → nullable
  │
  ├─ Is the taxonomy incomplete?
  │       └─ YES → other/unclear + detail
  │
  ├─ Is unexpected output dangerous?
  │       └─ YES → additionalProperties:false
  │
  ├─ Is output structurally valid but possibly wrong?
  │       └─ YES → semantic/business validation
  │
  ├─ Did validation fail recoverably?
  │       └─ YES → specific feedback + bounded retry
  │
  ├─ Is source evidence fundamentally absent?
  │       └─ YES → null/unclear or escalation
  │
  ├─ Is work latency-sensitive?
  │       └─ YES → synchronous
  │
  ├─ Is work bulk and latency-tolerant?
  │       └─ YES → Batch
  │
  ├─ Is the input very large?
  │       └─ YES → partition + integration pass
  │
  └─ Is reviewer independence important?
          └─ YES → fresh independent instance
```

---

# 14. CCA-F scenario patterns

## Scenario A — noisy code review

**Requirement:** Review pull requests but developers complain about hundreds of subjective findings.

**Best answer:** Define explicit report/skip criteria and severity boundaries; include boundary examples.

**Why:** The root problem is an ambiguous decision boundary and false positives.

---

## Scenario B — extraction returns invalid JSON

**Requirement:** Downstream application needs machine-readable output.

**Best answer:** Use structured output with a schema/tool contract rather than relying on “JSON only” instructions.

---

## Scenario C — optional source field

**Requirement:** A customer middle name may not exist.

**Best answer:** Make the field nullable rather than forcing the model to populate it.

---

## Scenario D — new category appears

**Requirement:** Controlled enum but real-world inputs may contain unknown categories.

**Best answer:** Add `other`/`unclear` plus a detail field and route novel cases appropriately.

---

## Scenario E — schema passes, total is wrong

**Requirement:** Invoice extraction has valid JSON but line-item total does not equal invoice total.

**Best answer:** Perform application-level semantic/business validation and retry with the exact discrepancy.

---

## Scenario F — retry keeps failing

**Requirement:** Model fails validation repeatedly.

**Best answer:** Stop after the retry budget and escalate; do not loop forever.

---

## Scenario G — nightly 1-million-record analysis

**Requirement:** Results can arrive later and cost matters.

**Best answer:** Batch processing, after sampling/testing the prompt and schema.

---

## Scenario H — pre-merge security gate

**Requirement:** The build must decide before merge.

**Best answer:** Synchronous processing because the result blocks a latency-sensitive workflow.

---

## Scenario I — 200-file codebase

**Requirement:** Find local and cross-file defects.

**Best answer:** Partition/per-file local analysis followed by cross-file integration synthesis; add independent review where required.

---

# 15. High-value distinctions to memorize

### 1. Explicit criteria vs few-shot

```text
Explicit criteria = define the rule
Few-shot examples = demonstrate the rule
```

### 2. Schema vs validation

```text
Schema = output shape
Validation = correctness
```

### 3. Multi-instance vs multi-pass

```text
Multi-instance = independence
Multi-pass = attention / scope
```

### 4. Sync vs Batch

```text
Sync = latency
Batch = throughput/cost when latency is flexible
```

### 5. Required vs nullable

```text
Guaranteed present = required
Legitimately absent = nullable
```

### 6. Enum vs `other`

```text
Known finite taxonomy = enum
Unknown real-world values = other/unclear + detail
```

### 7. Retry vs escalation

```text
Recoverable validation defect = retry
Missing evidence / repeated failure = escalate
```

### 8. Confidence vs evidence

```text
Confidence = routing signal
Evidence + validation = correctness basis
```

---

# 16. Practical lab sequence

Use the files in this directory in this order:

```text
01. Read prompt.md
       ↓
02. Inspect schema.json
       ↓
03. Run sample-input.json through the conceptual workflow
       ↓
04. Compare sample-output.valid.json
       ↓
05. Inspect sample-output.invalid.json
       ↓
06. Apply validation.md
       ↓
07. Practice targeted retry
       ↓
08. Study batch-plan.md
       ↓
09. Study review-architecture.md
       ↓
10. Rebuild the architecture from memory
```

### Hands-on exercises

1. Change a vague criterion into a categorical REPORT/SKIP rule.
2. Add two boundary examples to the prompt.
3. Make an optional field nullable.
4. Add an `other` category with a detail field.
5. Turn on `additionalProperties:false`.
6. Create an invalid output and identify every schema failure.
7. Create a semantically incorrect but structurally valid output.
8. Write a specific retry message for it.
9. Decide whether a workload should use Sync or Batch.
10. Partition a large review and design the integration pass.
11. Explain why a fresh reviewer is preferable to same-session self-review.
12. Design a confidence-based human escalation route.

---

# 17. Rapid revision sheet

```text
DOMAIN 4
│
├── PROMPT
│   ├── explicit criteria
│   ├── REPORT / SKIP
│   ├── severity definitions
│   ├── false-positive control
│   ├── few-shot boundary examples
│   ├── semantic prompt structure
│   └── never fabricate
│
├── STRUCTURED OUTPUT
│   ├── tool_use / schema
│   ├── tool_choice
│   │   ├── auto
│   │   ├── any
│   │   └── forced tool
│   ├── required
│   ├── nullable
│   ├── enum
│   ├── other / unclear
│   └── additionalProperties:false
│
├── VALIDATION
│   ├── structural
│   ├── semantic
│   ├── business
│   ├── specific retry
│   ├── bounded retry
│   └── escalation
│
├── SCALE
│   ├── Sync → real-time/blocking
│   ├── Batch → offline/bulk
│   ├── sample first
│   ├── custom_id
│   └── retry failed items only
│
└── REVIEW
    ├── partition
    ├── multi-pass
    ├── multi-instance
    ├── integration synthesis
    ├── merge/dedupe
    └── confidence → routing, not truth
```

---

# 18. Final exam checklist

Before selecting an answer, ask:

- [ ] Does the solution define explicit decision criteria?
- [ ] Does it reduce false positives rather than merely increase findings?
- [ ] Are difficult boundary cases demonstrated?
- [ ] Is machine-consumed output schema-constrained?
- [ ] Is `tool_choice` appropriate to the requirement?
- [ ] Are only genuinely guaranteed fields required?
- [ ] Can absent values be represented as `null`?
- [ ] Is there an `other`/`unclear` escape hatch where the taxonomy can evolve?
- [ ] Is schema drift prevented where appropriate?
- [ ] Is semantic correctness checked separately from structure?
- [ ] Does retry feedback identify the exact failure?
- [ ] Is retry bounded?
- [ ] Are fundamentally missing facts handled without fabrication?
- [ ] Is Sync chosen for latency-sensitive work?
- [ ] Is Batch reserved for latency-tolerant bulk work?
- [ ] Is the workload sampled before large-scale Batch submission?
- [ ] Can failed batch requests be selectively retried?
- [ ] Is a large review partitioned appropriately?
- [ ] Is cross-file integration checked?
- [ ] Is reviewer independence required?
- [ ] Is confidence being used as routing rather than truth?

If the answer satisfies these constraints, it is usually aligned with the Domain 4 architecture mindset.

---

## Source reconciliation note

This guide consolidates the Domain 4 study material supplied for this project and the supplied Gemini consolidation. Where the supplied material used slightly different heuristics (for example, 2–4 versus 2–5 examples or 1–2 versus 2–3 retries), this guide treats them as practical ranges rather than universal constants. Exact API behavior and certification requirements should be checked against the current official Anthropic/Claude certification documentation when doing final exam revision.
