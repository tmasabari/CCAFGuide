---
paths:
  - "**/migrations/**"
  - "**/*migration*.*"
---

# Migration-file rules

- Treat migrations as ordering-sensitive artifacts.
- Prefer additive, reversible changes when the target system allows it.
- Do not invent production data assumptions.
- Verify the application and migration compatibility before declaring success.
- For broad schema migrations with multiple viable approaches, plan first and obtain human approval before implementation.
