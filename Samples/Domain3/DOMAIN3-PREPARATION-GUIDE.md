# CCA-F Domain 3 Preparation Guide

> **Claude Code Configuration & Workflows — 20% of the CCA-F exam**

This guide consolidates the supplied CCA-F Study Guide, the Domain 3 lab/course material, the supplied Claude Code video series, and the additional consolidated notes prepared for this project. The **official study guide is the exam-authoritative source** when terminology or scope differs; broader lab/video material is retained as practical enrichment.

---

## 1. Domain 3 at a glance

The domain is easiest to remember as:

> **TEACH → PACKAGE → RESTRICT → AUTOMATE → REMEMBER → DELEGATE → CONNECT**

```text
                          Claude Code
                              │
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
  Shared context         Reusable workflows     Security boundaries
  CLAUDE.md               Commands / Skills     Permissions / deny
        │                     │                     │
        └──────────────┬──────┴──────────────┬─────┘
                       ↓                     ↓
                 Automation              Continuity
                  -p / JSON          memory / compaction
                       │                     │
                       └──────────┬──────────┘
                                  ↓
                     Delegation + integration
                     sub-agents / batch / MCP
```

The official exam framing centers on the following areas:

| Area | Core exam idea |
|---|---|
| CLAUDE.md hierarchy | Project/user/directory context and modular rules |
| `.claude/rules/` | Conditional loading for matching paths/globs |
| Commands | Version-controlled reusable workflows |
| Skills | Isolated execution and tool restrictions |
| Planning mode | Appropriate for large, ambiguous, architectural work |
| Direct execution | Appropriate for small, clear, well-understood changes |
| Headless CI/CD | `-p` / `--print` and machine-readable output |
| Independent review | Avoid same-session review bias |

The supplied Domain 3 lab additionally organizes the domain into seven nuggets: CLAUDE.md, slash commands, permissions, headless mode, persistent memory, multi-agent orchestration, and MCP integration. Those seven are retained here as a hands-on learning model.

---

# 2. Task 3.1 — Configure CLAUDE.md hierarchies

## 2.1 What CLAUDE.md is

Treat `CLAUDE.md` as a **persistent operating manual / job description** for Claude Code. It supplies project context before task-specific prompts and can encode technology choices, conventions, important commands, forbidden patterns, and architectural constraints.

```text
User prompt
    ↑
Relevant CLAUDE.md context already loaded
    ↑
Claude Code session starts
```

The supplied material emphasizes that this is not merely documentation for humans; it is active instruction context for Claude Code.

## 2.2 Three important scopes

The official study guide distinguishes:

```text
User-level
~/.claude/CLAUDE.md
  → personal preferences
  → not version-controlled with project

Project-level
CLAUDE.md or .claude/CLAUDE.md
  → shared repository standards
  → version-controlled

Directory-level
<subdirectory>/CLAUDE.md
  → package/service/local conventions
  → applies to that directory and descendants
```

**Exam trap:** placing shared project standards only in a user's home-level file means other contributors do not receive them.

A practical scope rule:

> Put stable project-wide conventions in the project file; put package-specific conventions closer to the package; keep personal preferences personal.

## 2.3 Modular imports with `@path`

Use `@path` references to avoid copying the same standard into several instruction files.

Example:

```markdown
# Project instructions

@./standards/testing.md
@./standards/api-contracts.md
```

The official study guide specifies `@path` imports and a maximum nesting depth of five.

## 2.4 `.claude/rules/` for conditional loading

Use `.claude/rules/` when a rule is cross-cutting but should load only for matching files.

Example:

```markdown
---
paths:
  - "**/*.test.*"
---

Follow repository test conventions.
```

Mental model:

```text
Whole project
   → project CLAUDE.md

One package / bounded directory
   → nearer directory CLAUDE.md

Pattern across many directories
   → .claude/rules/*.md + paths:
```

Do not overstate this as a single total precedence ladder between every mechanism. The reliable exam principle is **use the most appropriate and most specific applicable scope**.

## 2.5 Good CLAUDE.md content

Strong examples include:

- tech stack and supported versions;
- coding conventions that materially affect generated code;
- build/test commands;
- architectural boundaries;
- protected files/areas;
- explicit `Never do` rules;
- references to shared standards.

Avoid turning `CLAUDE.md` into a giant, stale encyclopedia. Keep it relevant to Claude's work.

## 2.6 Guidance is not deterministic enforcement

A critical architecture distinction:

```text
CLAUDE.md / prompts
      ↓
behavioral guidance
      ↓
probabilistic compliance

settings / permissions / hooks / CI gates
      ↓
deterministic enforcement boundary
```

Do not use prose instructions as the only control for destructive or security-critical actions.

---

# 3. Task 3.2 — Create and manage custom slash commands

## 3.1 Project commands

Project commands live in `.claude/commands/` and are version-controlled with the repository.

Typical examples:

```text
/project:review
/project:explain src/auth/jwt.ts
/project:onboard
```

The supplied course material recommends verb-oriented names for discoverability.

## 3.2 Parameterization

Use `$ARGUMENTS` to build reusable workflows.

Example:

```markdown
---
name: explain
description: Explain a specified file in repository context.
---

Explain the code in `$ARGUMENTS`.
Cover purpose, design, edge cases, and test gaps.
```

Then:

```text
/project:explain src/auth/jwt.ts
```

## 3.3 Commands vs Skills

A useful study distinction:

| Mechanism | Best mental model |
|---|---|
| CLAUDE.md | Always-relevant project guidance |
| Command | Reusable named workflow invoked explicitly |
| Skill | Packaged capability/workflow with configurable execution behavior |

Skills in the supplied study material support frontmatter such as:

```yaml
context: fork
allowed-tools:
  - Read
  - Grep
  - Glob
argument-hint: [scope]
```

### `context: fork`

Use `context: fork` when verbose exploration should run in an isolated subagent/context so the main session is not polluted by all exploratory output.

### `allowed-tools`

Use it to restrict the tool surface available to the skill. This is an important **security boundary**.

### `argument-hint`

Use it to signal expected parameters for an invoked skill.

---

# 4. Task 3.3 — Configure permissions

## 4.1 Least privilege is the primary principle

Grant only what the task requires.

```text
Code review
  → Read + Grep + Glob

Documentation generation
  → Read + Write (as needed)

Analysis-only CI
  → explicit read-oriented tool set

Full agentic development
  → broader access only when justified and appropriately isolated
```

## 4.2 `--allowedTools`

Use `--allowedTools` to constrain a session to the smallest useful tool surface.

Examples from the supplied material:

```text
--allowedTools Read,Grep,Glob
```

for read-only review, or a narrowly scoped combination for a controlled automation workflow.

## 4.3 Deny rules

Project settings can include explicit deny patterns for dangerous operations.

Example in this sample:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git reset --hard:*)",
      "Bash(git push --force:*)"
    ]
  }
}
```

Mental model:

```text
allow = permission candidates

deny = hard safety boundary
```

When an operation is explicitly denied, do not rely on a broad allow to make it safe.

## 4.4 `--dangerously-skip-permissions`

The supplied Domain 3 material treats this as appropriate only in **isolated Docker/container environments**, not on a developer workstation.

Exam-safe rule:

> Never use this as a shortcut on a developer machine.

---

# 5. Task 3.4 — Headless mode and CI/CD

## 5.1 The critical flag: `-p`

The official study guide identifies `-p` / `--print` as the correct mode for non-interactive pipeline execution.

```text
Interactive:
claude "Analyze ..."

CI:
claude -p "Analyze ..."
```

**Exam trap:** using the interactive form in CI can leave the job waiting for input.

## 5.2 Pipe Unix data into Claude

Headless Claude can compose with existing command-line workflows.

```bash
git diff main | claude -p "Review this change"
```

or:

```bash
cat error.log | claude -p "Identify likely root causes"
```

## 5.3 Machine-readable output

For pipelines, use structured output rather than scraping prose.

The supplied material emphasizes:

```text
claude -p --output-format json "..."
```

with fields such as `result`, `is_error`, `total_cost_usd`, and `session_id` in the referenced course example.

The official study guide further emphasizes using `--json-schema` when structured results need a specific machine-validated shape.

## 5.4 CI review architecture

Recommended pattern:

```text
PR / change
   ↓
CI worker
   ↓
claude -p
   ↓
structured result
   ↓
application / pipeline logic
   ↓
review findings
```

For review itself:

```text
Code-generation session
        X
     same-instance self-review

          ↓ better

Fresh independent review instance
```

Why? A session that generated the code can share the same blind spots and confirmation bias.

## 5.5 Avoid duplicate findings

For repeated PR review, provide prior review results as context and tell the reviewer to surface only **new/unresolved** issues.

Do not blindly suppress a finding because it resembles an older finding; verify whether the issue is actually fixed.

## 5.6 Advisory vs authoritative CI controls

This sample uses graceful degradation because the Claude review is explicitly **advisory**.

```text
Claude unavailable
      ↓
log / skip review
      ↓
continue
```

That is not the same as saying AI should always be allowed to bypass security/compliance gates.

For critical deterministic controls:

```text
security / compile / unit-test gate
          ↓
     authoritative

AI review
          ↓
 advisory / enrichment
```

---

# 6. Task 3.5 — Session memory and persistent context

The supplied Domain 3 lab treats memory and context continuity as a distinct learning objective.

## 6.1 `/memory`

Use `/memory` as a diagnostic/inspection mechanism for memory-related behavior and stored context in workflows where it applies.

Mental model:

```text
Session context
      ↓
useful observations
      ↓
compressed / persistent memory where configured
      ↓
future continuity
```

## 6.2 `/compact`

Compaction can reduce context pressure, but compression can lose detail.

A useful study warning is:

> After compaction, verify important numbers, dates, exact constraints, and unresolved decisions rather than assuming every detail survived unchanged.

## 6.3 Stale-context trap

Memory continuity does **not** mean the filesystem or external world has magically been refreshed.

Example:

```text
Session observes file X
        ↓
Another process changes file X
        ↓
Old session still has prior observation
        ↓
Risk: stale reasoning
```

Re-read relevant files when external changes matter.

---

# 7. Task 3.6 — Multi-agent orchestration

## 7.1 When delegation helps

Multi-agent work is strongest when the task is:

1. large enough to benefit from parallel execution; and
2. decomposable into genuinely independent work units.

Examples in the supplied course material include broad documentation, test generation, and other repetitive codebase-wide work.

## 7.2 Independence test

Ask:

> Can each unit be completed without needing the output of another unit?

```text
Independent
A ──┐
B ──┼→ parallel → aggregate / review
C ──┘

Dependent
A → B → C
     ↓
 sequential is safer
```

Do not use parallel agents simply because a task is large. Interdependence is the deciding factor.

## 7.3 `/batch`

The supplied course material describes `/batch` as a built-in workflow that can decompose large changes into independent units and use isolated worktrees / pull requests.

A safe pattern is:

```text
Large request
    ↓
inspect decomposition plan
    ↓
human correction / approval
    ↓
parallel agents
    ↓
separate PRs
    ↓
selective review + merge
```

The course recommends reviewing the plan before execution so decomposition errors are corrected before many PRs are created.

## 7.4 Sub-agent context

Sub-agents have their own context and tool access. Do not assume sibling agents automatically share the coordinator's full context.

## 7.5 Parallel vs sequential

A practical rule:

```text
Same task, shared dependencies, ordering-sensitive
   → sequential

Independent repetitive units
   → parallel / batch
```

The supplied course's numeric heuristics such as “5 files” or “20+ units” are useful teaching examples, not universal laws.

---

# 8. Task 3.7 — MCP integration

**Important source-scope note:** MCP is also a major topic in Domain 2 in the official study guide. Domain 3 learning includes its use inside Claude Code workflows, but MCP fundamentals should be studied primarily under Domain 2.

## 8.1 MCP mental model

```text
Claude Code
    │
    │ MCP client
    ↓
MCP server
    │
    ├── external tools
    ├── resources / data
    └── integrations
```

## 8.2 Team vs personal configuration

The supplied material distinguishes local/project configuration from global/user configuration.

The broader course material references `.claude/.mcp.json` for project sharing and `~/.claude.json` for user/global configuration. Use the exact configuration model applicable to your installed Claude Code version and the official documentation when implementing beyond this study sample.

## 8.3 CI permission scoping

MCP tools should be treated like any other tool surface: allow only what CI requires.

The supplied material uses the `mcp__<servername>` naming pattern in `--allowedTools` examples.

Illustrative pattern:

```text
Read,Grep,Glob,
 mcp__github__list_pull_requests,
 mcp__github__get_pull_request
```

Do not include write operations when the workflow only needs read access.

## 8.4 Secrets

Never commit credentials in MCP configuration or repository source.

```text
CI secret store / environment
        ↓
credential injection at runtime
        ↓
MCP client / server
```

## 8.5 Graceful degradation

Use MCP as an enhancement when the core workflow can safely continue without it.

```text
MCP available
   → enriched review

MCP unavailable
   → local fallback / reduced capability
```

For a critical external integration, define explicitly whether failure should block the workflow. Do not blindly treat every MCP outage as non-fatal.

---

# 9. Planning mode vs direct execution

This distinction is explicitly emphasized by the official study guide.

| Scenario | Preferred approach |
|---|---|
| Large change | Planning mode first |
| Multiple viable approaches | Planning mode first |
| Architectural decision | Planning mode first |
| Unfamiliar codebase | Planning mode first |
| Single-file fix | Direct execution |
| Clear stack trace | Direct execution |
| Well-understood unambiguous change | Direct execution |

Best combined pattern:

```text
Investigate / understand
        ↓
Planning mode
        ↓
Proposed approach
        ↓
human review / approval
        ↓
Direct execution
        ↓
validation
```

The broader video/course material sometimes gives numeric heuristics for when planning “should” be used. Treat those as teaching heuristics, not universal exam requirements.

---

# 10. Consolidated architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code Session                     │
└─────────────────────────────────────────────────────────────┘
                │
                ├──────────── Shared guidance ───────────────┐
                │                                             │
                │   user CLAUDE.md                            │
                │   project CLAUDE.md                         │
                │   directory CLAUDE.md                       │
                │   .claude/rules/*.md                        │
                │   @imports                                  │
                │                                             │
                ├──────────── Reusable workflows ─────────────┤
                │                                             │
                │   .claude/commands/                         │
                │   .claude/skills/                           │
                │   $ARGUMENTS                                │
                │   context: fork                             │
                │   allowed-tools                             │
                │                                             │
                ├──────────── Security boundary ─────────────┤
                │                                             │
                │   permissions                               │
                │   --allowedTools                            │
                │   deny rules                                │
                │                                             │
                ├──────────── Automation ─────────────────────┤
                │                                             │
                │   -p / --print                              │
                │   --output-format json                      │
                │   --json-schema                             │
                │   CI review / hooks / scripts               │
                │                                             │
                ├──────────── Continuity ─────────────────────┤
                │                                             │
                │   /memory                                   │
                │   /compact                                  │
                │   stale-context awareness                   │
                │                                             │
                ├──────────── Delegation ─────────────────────┤
                │                                             │
                │   sub-agents                                │
                │   /batch                                    │
                │   worktree / PR isolation                   │
                │                                             │
                └──────────── Integration ─────────────────────┘
                                                              │
                MCP servers / external tools / resources ─────┘
```

---

# 11. Practical best-practice checklist

## Configuration

- Shared project standards are in version-controlled project configuration.
- Personal preferences are not mistaken for team standards.
- Package-local guidance is scoped near the package.
- Cross-cutting rules use `.claude/rules/` with appropriate `paths:`.
- Repeated standards use `@imports` instead of copy/paste.
- Important constraints include explicit negative guidance.

## Permissions

- Least privilege is the default.
- `--allowedTools` is narrow and task-specific.
- Dangerous operations have explicit deny boundaries where needed.
- `--dangerously-skip-permissions` is not used on developer workstations.

## Commands and Skills

- Commands represent repeated workflows.
- `$ARGUMENTS` is used for reusable parameterization.
- Skills use `context: fork` when isolation is beneficial.
- Skills use `allowed-tools` to constrain their capability surface.

## Planning and execution

- Large/ambiguous/architectural changes get a plan first.
- Human review occurs before high-impact implementation.
- Small, clear, well-understood changes can be executed directly.

## CI/CD

- Use `claude -p` / `--print` for non-interactive execution.
- Prefer structured JSON / schema-backed output for machine processing.
- Use an independent review instance when reviewer independence matters.
- Feed prior review context to avoid duplicate findings.
- Decide explicitly whether AI failure is advisory or blocking.

## Memory

- Use memory tools intentionally rather than assuming automatic correctness.
- Re-check critical facts after compaction.
- Re-read files when external changes may have made prior context stale.

## Multi-agent

- Parallelize only independent work.
- Review the decomposition before execution.
- Prefer isolation and selective merge.
- Do not assume agents share context automatically.

## MCP

- Treat MCP as an external capability boundary.
- Scope MCP tool permissions narrowly.
- Keep secrets in runtime secret management.
- Provide a fallback when MCP is optional to the workflow.

---

# 12. High-value exam traps

| Question pattern | Correct instinct |
|---|---|
| “How does every contributor receive project standards?” | Project-level version-controlled `CLAUDE.md` |
| “Where should a personal preference go?” | User-level configuration |
| “Same rule, many scattered file types/dirs?” | `.claude/rules/` + `paths:` |
| “Same command repeated by the team?” | `.claude/commands/` |
| “Parameterized reusable command?” | `$ARGUMENTS` |
| “Verbose skill exploration should not pollute main session?” | `context: fork` |
| “Restrict what a skill/session can call?” | `allowed-tools` / `--allowedTools` |
| “CI Claude command hangs?” | `claude -p` / `--print` |
| “Pipeline must parse result safely?” | JSON output / schema |
| “Generation session should review its own code?” | Prefer independent review instance when independence matters |
| “Large architectural change?” | Planning mode first |
| “Simple clear single-file bug?” | Direct execution |
| “Parallelize tightly coupled changes?” | No; use sequential coordination |
| “MCP token in repository config?” | Never commit secrets |
| “AI review unavailable, but review is advisory?” | Graceful degradation |
| “CLAUDE.md used as only security control?” | Wrong; use deterministic permission/enforcement layers |

---

# 13. Domain 3 mini mind map

```text
DOMAIN 3 — Claude Code Configuration & Workflows
│
├── 3.1 CLAUDE.md
│   ├── user
│   ├── project
│   ├── directory
│   ├── @imports
│   └── .claude/rules + paths:
│
├── 3.2 Commands / Skills
│   ├── .claude/commands/
│   ├── $ARGUMENTS
│   ├── context: fork
│   ├── allowed-tools
│   └── argument-hint
│
├── 3.3 Permissions
│   ├── least privilege
│   ├── --allowedTools
│   ├── deny rules
│   └── avoid dangerous bypasses
│
├── 3.4 Headless / CI
│   ├── -p / --print
│   ├── stdin/stdout
│   ├── JSON / schema
│   ├── independent review
│   └── duplicate prevention
│
├── 3.5 Memory
│   ├── /memory
│   ├── /compact
│   └── stale context
│
├── 3.6 Multi-agent
│   ├── independent tasks
│   ├── /batch
│   ├── sub-agents
│   └── isolation / selective merge
│
└── 3.7 MCP
    ├── server integration
    ├── tool scoping
    ├── secret management
    └── graceful fallback
```

---

# 14. Recommended hands-on sequence

Use the files in this sample folder in this order:

```text
1. CLAUDE.md
        ↓
2. standards/*
        ↓
3. .claude/rules/*
        ↓
4. .claude/commands/*
        ↓
5. .claude/skills/*
        ↓
6. .claude/settings.json
        ↓
7. ci_claude_review.sh + validate_ci_review.py
        ↓
8. pitfalls.md
        ↓
9. /batch + sub-agent design (conceptual)
        ↓
10. .mcp.json.example (conceptual / optional)
```

For each section, do three things:

1. **Explain it** in your own words.
2. **Predict the architectural outcome** before running the example.
3. **Identify the failure mode** the pattern is designed to prevent.

That produces stronger exam recall than memorizing isolated flags.

---

# 15. Source reconciliation notes

This repository intentionally combines material with slightly different taxonomies.

### Exam authority

The official CCA-F Study Guide is the primary source for exam task statements and distinctions. In particular, it explicitly covers:

- user → project → directory `CLAUDE.md` hierarchy;
- `@path` imports and `.claude/rules/paths:` conditional loading;
- project vs user commands;
- Skills `context: fork`, `allowed-tools`, `argument-hint`;
- planning mode vs direct execution;
- `-p` / `--print`, JSON output, independent review, and duplicate-finding prevention.

### Course/lab enrichment

The supplied Domain 3 lab expands the topic into seven practical nuggets and includes hands-on examples for permissions, memory, multi-agent orchestration, and MCP.

### Video enrichment

The supplied video series contributes practical explanations around:

- CLAUDE.md as a persistent job description;
- path-specific rules;
- commands and Skills;
- Plan Mode followed by direct execution;
- iterative refinement and explicit examples;
- CI/CD headless execution and independent review.

Some iterative-refinement material also overlaps with Domain 4, so it is best treated as cross-domain reinforcement rather than an exclusive Domain 3 boundary.

### Important scope correction

MCP is a major Domain 2 topic in the official Study Guide even though the supplied Domain 3 lab includes an MCP nugget. Do not let the overlap cause Domain 2 MCP preparation to be skipped.

---

# 16. Final mental model

When faced with a CCA-F Domain 3 scenario, ask these questions in order:

```text
1. What context must Claude always know?
      → CLAUDE.md / scoped rules

2. Is this workflow repeated?
      → command / skill

3. What tools are actually necessary?
      → least privilege / allowed tools / deny

4. Is this interactive or automated?
      → direct session vs -p

5. Does the pipeline need machine-readable output?
      → JSON / schema

6. Is the change large or ambiguous?
      → plan first

7. Are work units truly independent?
      → parallelize / batch

8. Does review independence matter?
      → fresh review instance

9. Does the workflow depend on persistent or historical context?
      → memory + refresh for changed external state

10. Does it need external systems?
      → MCP, narrowly scoped, secret-safe, fallback-aware
```

> **Domain 3 is not about memorizing commands. It is about choosing the right configuration and workflow boundary for the job.**
