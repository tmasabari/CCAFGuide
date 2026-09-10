---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
---

# Test-file rules

- Follow the existing test framework and assertion style.
- Prefer deterministic unit tests for isolated logic.
- Do not introduce network calls into unit tests.
- Keep fixtures minimal and representative.
- When changing behavior, update or add tests that demonstrate the intended behavior.
