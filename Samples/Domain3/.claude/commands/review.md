---
name: review
description: Review the current change for correctness, security, reliability, tests, and project conventions.
allowed-tools: Read,Grep,Glob
---

Review the current working-tree or staged change.

Scope:
1. Inspect the relevant diff and supporting files.
2. Check correctness, security, reliability, error handling, and test coverage.
3. Use the project's CLAUDE.md and applicable `.claude/rules/` guidance.
4. Do not report style-only preferences unless they are project rules with concrete impact.
5. Do not invent runtime behavior, APIs, test results, or facts not supported by the repository.

Output:
- Findings ordered by severity.
- For each finding: file, evidence, impact, and recommended fix.
- If no actionable issue is found, say `No actionable findings`.
