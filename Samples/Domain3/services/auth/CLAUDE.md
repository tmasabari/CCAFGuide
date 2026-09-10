# Auth Service — Scoped Rules

## Local conventions

- Authentication and authorization changes require focused review before merge.
- Do not hardcode token expiry values when they should come from configuration.
- Treat authentication failures and authorization failures as distinct cases.

## Never do

- Never commit signing keys, client secrets, session secrets, or bearer tokens.
- Never weaken authorization checks to make a happy-path test pass.
- Never log raw access tokens or session credentials.
