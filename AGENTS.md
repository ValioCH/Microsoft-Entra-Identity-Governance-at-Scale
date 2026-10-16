# Repository Operating Rules

## Evidence and claims

- Never describe a control as deployed or verified without a dated reproducible test and Evidence ID.
- Keep planned architecture, configured state and verified results visibly separate.
- Synthetic scale tests demonstrate automation behavior, not production operation at enterprise scale.

## Cloud changes

- Default to read-only discovery.
- Obtain explicit approval before every material Microsoft Entra, Microsoft 365 or Azure change.
- Before requesting approval, state scope, permissions, cost, risk, validation and rollback.
- Never combine discovery and apply operations in one opaque script.

## Security and privacy

- Never store tenant IDs, subscription IDs, object IDs, full UPNs, passwords, secrets, tokens, certificates, recovery codes, private URLs, public IP addresses or live connection identifiers.
- Use sanitized labels and local parameter files excluded by `.gitignore`.
- Prefer managed identity or workload identity federation over client secrets.
- Do not use emergency-access identities for routine administration or automation.

## Repository workflow

- Preserve unrelated changes and keep commits small.
- Do not commit, push, create a pull request or publish without explicit approval.
- Prefer parameterized and idempotent automation with preview, validation and rollback.

