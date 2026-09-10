# Payments Service — Scoped Rules

## Local conventions

- Treat monetary values using the service's established integer/minor-unit representation.
- Never log full payment-card numbers, CVVs, authentication secrets, or equivalent sensitive payment data.
- Payment side effects must be reviewed carefully when introducing retries or idempotency changes.

## Never do

- Never add credentials to source code.
- Never weaken payment validation merely to make a test pass.
- Never expose provider secrets in logs or error responses.
