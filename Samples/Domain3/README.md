# CCA-F Domain 3 — Claude Code Configuration & Workflows Sample

A production-oriented reference implementation for **Domain 3: Claude Code Configuration & Workflows**.

This sample is designed for hands-on CCA-F preparation. It demonstrates the configuration and workflow patterns covered by the Domain 3 study material, while keeping security-sensitive or environment-specific values as placeholders.

## Learning objectives

```text
TEACH
  ↓
PACKAGE
  ↓
RESTRICT
  ↓
AUTOMATE
  ↓
REMEMBER
  ↓
DELEGATE
  ↓
CONNECT
```

The sample covers:

1. `CLAUDE.md` hierarchy and modular imports
2. Path-specific rules with `.claude/rules/`
3. Project slash commands and parameterization
4. Skills with isolated context and restricted tools
5. Least-privilege permission design and deny rules
6. Headless `-p` automation and JSON output
7. Safe CI/CD review with graceful degradation
8. Memory, compaction, and stale-context awareness
9. Independent multi-agent review / `/batch` decomposition concepts
10. Optional MCP integration with explicit tool scoping and secret handling

## Directory layout

```text
Samples/Domain3/
├── README.md
├── DOMAIN3-PREPARATION-GUIDE.md
├── CLAUDE.md
├── .claude/
│   ├── settings.json
│   ├── settings.local.example.json
│   ├── commands/
│   │   ├── review.md
│   │   ├── explain.md
│   │   └── onboard.md
│   ├── rules/
│   │   ├── tests.md
│   │   └── migrations.md
│   └── skills/
│       └── repository-review/
│           └── SKILL.md
├── services/
│   ├── payments/
│   │   └── CLAUDE.md
│   └── auth/
│       └── CLAUDE.md
├── standards/
│   ├── testing.md
│   └── api-contracts.md
├── .mcp.json.example
├── ci_claude_review.sh
├── validate_ci_review.py
├── sample-input.diff
└── pitfalls.md
```

## How to use

Start Claude Code from this directory or from one of the example service folders and inspect which instructions are in scope.

Recommended study flow:

```text
1. Read DOMAIN3-PREPARATION-GUIDE.md
2. Inspect CLAUDE.md and the scoped rule files
3. Try /project:review and /project:explain
4. Inspect settings.json and identify the security boundaries
5. Run ci_claude_review.sh in a safe test repository
6. Read pitfalls.md and explain why each pitfall is dangerous
7. Study the multi-agent and MCP sections before experimenting
```

## Safety notes

- The repository intentionally uses **example** MCP configuration rather than real credentials.
- Do not put API keys, OAuth tokens, passwords, or production endpoints into committed files.
- Do not use `--dangerously-skip-permissions` on a developer workstation.
- Treat `CLAUDE.md` as guidance, not as a deterministic security boundary. Use permission settings and application controls for enforcement.
- CI fallback is appropriate only where AI review is advisory. A workflow that must hard-fail on a security/compliance control needs a deterministic gate as the authoritative control.

## Exam mental model

> **Shared context → reusable workflow → least privilege → non-interactive execution → continuity → decomposition → external tools**
