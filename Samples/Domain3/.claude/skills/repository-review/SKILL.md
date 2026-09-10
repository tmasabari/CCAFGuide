---
name: repository-review
description: Perform a focused repository review without polluting the main session with verbose exploration.
context: fork
allowed-tools:
  - Read
  - Grep
  - Glob
argument-hint: [path-or-scope]
---

Review the requested repository scope for actionable correctness, security, reliability, maintainability, and test-coverage issues.

Rules:
- Read only the relevant files needed to support findings.
- Respect project CLAUDE.md and applicable path-scoped rules.
- Do not invent behavior or test results.
- Prefer concrete evidence over speculation.
- Ignore style-only preferences unless explicitly required by repository guidance.

Return:
1. findings ordered by severity;
2. evidence and affected paths;
3. recommended fixes;
4. unresolved questions.

If the scope is `$ARGUMENTS` and it is empty, review the current working tree at a high level before narrowing to relevant files.
