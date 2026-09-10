# Validation, Retry, and Escalation

## 1. Structural validation

Validate the model response against `schema.json` before accepting it.

The intentionally invalid sample demonstrates several failures:

- `severity=urgent` is outside the enum.
- `category=performance` is outside the controlled vocabulary.
- `evidence=null` is invalid for a `REPORT` result under the conditional rule.
- `confidence=1.2` exceeds the allowed range.
- `extra_reason` violates `additionalProperties: false`.

## 2. Semantic validation

A schema can prove that the output has the right shape; it cannot prove that the finding is true.

Validate business semantics separately:

- `REPORT` must have evidence grounded in the supplied input.
- A severity must match the stated impact.
- A suggested fix must address the finding rather than introduce unrelated changes.
- Do not report style preferences as defects.
- Do not fabricate missing evidence.

## 3. Specific retry feedback

Bad:

```text
Try again. The output is invalid.
```

Good:

```text
Field: severity
Produced value: urgent
Error: value is not one of critical, high, medium, low, or null
Expected correction: choose one allowed severity or null if the decision is SKIP.
```

For semantic failures, identify the exact claim that is unsupported and tell the model what evidence or decision rule must be reconsidered.

## 4. Bounded retry loop

```text
Generate
  ↓
Schema validation
  ├─ PASS → semantic validation
  └─ FAIL → specific error feedback
                 ↓
               retry
                 ↓
          max 2–3 attempts
                 ↓
        unresolved → human review
```

Do not retry indefinitely. Some failures are not recoverable by asking the same model again.

## 5. Escalation

Escalate when:

- repeated validation failures remain after the retry budget;
- required evidence is genuinely absent;
- the taxonomy cannot represent the case safely;
- the decision has material consequences and evidence remains ambiguous.

`confidence` may help route borderline cases to human review, but should not be used as proof of correctness.
