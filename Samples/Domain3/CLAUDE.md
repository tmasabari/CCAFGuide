# Domain 3 Sample — Claude Code Operating Rules

## Project purpose

This folder is a CCA-F Domain 3 learning/sample environment. Use it to study Claude Code configuration and workflow patterns.

## Repository context

- Treat files under `Samples/Domain3/` as examples and training material.
- Prefer small, reviewable changes.
- Do not invent project facts when evidence is absent.
- Explain assumptions when a sample necessarily uses placeholders.

## Standard workflow

1. Inspect the relevant files before changing them.
2. For broad architectural or multi-file changes, use planning first and obtain human approval before execution.
3. For simple, well-understood fixes, direct execution is acceptable.
4. Validate generated changes before declaring success.
5. Keep security-sensitive values out of version control.

## Tool and permission principles

- Default to least privilege.
- Use read-only tools for analysis/review whenever possible.
- Do not request broad write or shell access when narrower access is sufficient.
- Never use `--dangerously-skip-permissions` on a developer machine.

## Never do

- Never commit API keys, OAuth tokens, passwords, private keys, or other secrets.
- Never hardcode production credentials in examples.
- Never disable deterministic validation merely because Claude produced structured output.
- Never claim tests passed unless they were actually run and the result is available.
- Never rely on CLAUDE.md alone as a security boundary.

## Key commands

- Tests: use the repository's actual test command for the target project.
- Review sample: `/project:review`
- Explain a file: `/project:explain <path>`
- Onboard: `/project:onboard`

## Imported shared standards

@./standards/testing.md
@./standards/api-contracts.md

## Scope model

- Project-wide standards belong here.
- Cross-cutting file-pattern guidance belongs under `.claude/rules/`.
- Package/service-specific guidance belongs in a nearer `CLAUDE.md`.
- Personal preferences belong in a user's own Claude configuration, not in this shared sample.
