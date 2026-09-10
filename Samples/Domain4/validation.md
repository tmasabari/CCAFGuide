# Validation, Retry, and Escalation

## 1. Structural validation

Validate the model response against `schema.json` before accepting it.

The intentionally invalid sample demonstrates several failures:

- `severity=urgent` is outside the enum.
- `category=performance` is outside the controlled vocabulary.
- `evidence=null` is invalid for a `REPORT` result under the conditional rule.
- `confidence=1.2` exceeds the allowed range.
- `extra_reason` violates `additionalProperties: false`.

## 2. Semantic and business validation

A schema can constrain the output shape; it cannot by itself prove that a finding is true or that the business logic is correct.

Validate separately in deterministic application code:

- `REPORT` must have evidence grounded in the supplied input.
- Severity must match the stated impact.
- A suggested fix must address the finding.
- Style preferences must not be promoted to defects.
- Missing evidence must not be fabricated.

## 3. Specific retry feedback

Bad:

```text
Try again. The output is invalid.
```

Good:

```text
Field: severity
Produced value: urgent
Error: value is outside the allowed enum.
Expected correction: choose critical, high, medium, low, or null as permitted by the decision.
```

For semantic failures, identify the exact unsupported claim and the rule/evidence that must be reconsidered.

## 4. Bounded retry loop

```text
Generate
  ↓
Structural validation
  ├─ PASS → semantic/business validation
  └─ FAIL → specific error feedback
                 ↓
               retry
                 ↓
            max 2–3 attempts
                 ↓
       unresolved / missing evidence
                 ↓
          human review escalation
```

Retry only when another generation has a reasonable chance of correcting the problem. If the source genuinely does not contain the information, prefer `null`, `other`, `unclear`, `SKIP`, or escalation according to the schema and business policy rather than retrying to force a value.

## 5. Escalation

Escalate when:

- repeated validation failures remain after the retry budget;
- required evidence is genuinely absent;
- the taxonomy cannot represent the case safely;
- the decision has material consequences and evidence remains ambiguous.

`confidence` can help route borderline cases to human review, but a self-reported confidence score is not proof of correctness.
