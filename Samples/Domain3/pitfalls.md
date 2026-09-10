# Domain 3 Pitfalls & Exam Traps

| Pitfall | Better choice |
|---|---|
| Put shared project standards only in `~/.claude/CLAUDE.md` | Put team standards in project-level `CLAUDE.md` so they are version-controlled and shared |
| Duplicate large rules across many CLAUDE.md files | Use `@path` imports for shared material |
| Use root guidance for every file type | Use `.claude/rules/` with `paths:` for cross-cutting/file-pattern rules |
| Put package-specific rules in a global file | Put them in the nearer directory `CLAUDE.md` |
| Treat CLAUDE.md prose as a hard security boundary | Use permission settings and deterministic application controls |
| Grant all tools to every automated task | Apply least privilege and explicit `--allowedTools` |
| Use `--dangerously-skip-permissions` on a developer machine | Avoid it; only consider isolated disposable environments where appropriate |
| Allow a dangerous Bash command because another rule allows it | Remember that explicit deny rules are the stronger safety boundary |
| Run `claude "..."` in CI | Use `claude -p "..."` / `--print` for non-interactive execution |
| Parse human prose to determine CI success | Use structured JSON output and explicit status fields |
| Make an advisory AI outage fail the deployment | Gracefully degrade when Claude is optional; keep deterministic gates authoritative |
| Assume session continuity means filesystem state is fresh | Re-inspect the filesystem after external changes; avoid stale observations |
| Use `/batch` for tightly coupled changes | Batch only when work units can be completed independently |
| Assume sibling sub-agents share context automatically | Explicitly provide required context; each agent has its own context/tool surface |
| Make every skill broadly privileged | Use `allowed-tools` to restrict a skill's tool surface |
| Use `context: fork` when the main session needs all exploratory detail | Use it when isolation of verbose work is valuable |
| Put MCP credentials in `.mcp.json` | Store credentials in environment/secret management, never committed source |
| Give CI MCP write access when read access is sufficient | Enumerate only required MCP tools in `--allowedTools` |
| Make MCP a single point of failure for a critical CI path | Design a local fallback where MCP is an enhancement rather than the authority |
| Claim an action succeeded because Claude said it did | Verify via deterministic checks, commands, tests, or external systems |

## High-value exam distinctions

### Project vs user configuration

```text
Shared team standard
      ↓
project CLAUDE.md / project commands
      ↓
version-controlled → other contributors receive it

Personal preference
      ↓
user-level Claude configuration
      ↓
not a team-shared repository standard
```

### Directory rules vs path-scoped rules

```text
Directory/package convention
   → nearer directory CLAUDE.md

Cross-cutting file pattern
   → .claude/rules/*.md with paths:
```

### Planning vs direct execution

```text
Large / ambiguous / architectural
      → plan → investigate → human approval → execute

Small / clear / unambiguous
      → direct execution
```

### CI

```text
Interactive session          CI worker
       │                         │
       ↓                         ↓
   claude ...              claude -p ...
                                  │
                                  ↓
                       --output-format json
                                  │
                                  ↓
                    machine-readable handling
```

## Source-status note

The repository combines the official CCA-F study guide with the supplied Domain 3 lab/course material and practical video-derived enrichment. Where the materials use broader or overlapping taxonomies, this guide prioritizes the official exam framing for exam decisions and labels broader operational guidance as supporting material.
