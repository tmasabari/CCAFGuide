#!/usr/bin/env python3
"""Validate the minimal Claude headless JSON envelope used by the sample."""

import json
import sys


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError as exc:
        print(f"Invalid JSON from Claude: {exc}", file=sys.stderr)
        return 1

    required = {"result", "is_error"}
    missing = required.difference(data)
    if missing:
        print(f"Missing required fields: {sorted(missing)}", file=sys.stderr)
        return 1

    if not isinstance(data["is_error"], bool):
        print("is_error must be boolean", file=sys.stderr)
        return 1

    if data["is_error"]:
        print("Claude reported an error", file=sys.stderr)
        return 1

    if not isinstance(data["result"], str):
        print("result must be a string", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
