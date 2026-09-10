#!/usr/bin/env bash
set -u

# Advisory Claude review for CI. Keep deterministic CI gates authoritative.
# Required environment: a working Claude Code installation and authentication.

DIFF="$(git diff HEAD~1 2>/dev/null || true)"
if [[ -z "$DIFF" ]]; then
  echo "No diff available; skipping AI review."
  exit 0
fi

echo "Running headless Claude review..."

if ! RESULT="$(printf '%s\n' "$DIFF" | claude -p --output-format json \
  --allowedTools Read,Grep,Glob \
  "Review this diff for actionable correctness, security, reliability, and test gaps. Do not invent facts. Report findings with file, evidence, impact, and recommended fix. Focus only on new or unresolved issues.")"; then
  echo "AI review unavailable; continuing because this review is advisory."
  exit 0
fi

if ! python3 validate_ci_review.py <<<"$RESULT"; then
  echo "Claude returned an unusable review response; continuing because this review is advisory."
  exit 0
fi

printf '%s\n' "$RESULT" | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"])'
exit 0
