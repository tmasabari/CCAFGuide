# API Contract Standards

- API responses should follow the target service's established contract.
- Do not invent fields or infer undocumented behavior.
- Never expose raw database errors to clients.
- Dates and times must follow the service's documented representation.
- Validate request and response contracts at deterministic application boundaries.
