# Identity Lifecycle Pipeline

## Status

**Configured** locally. The source workbook, deterministic scale generator and offline preflight pipeline exist. No Graph apply adapter or cloud workload identity is approved or configured.

## Architecture

`HR source -> schema validation -> deterministic change plan -> human approval -> Graph apply -> state verification -> evidence and rollback`

## Separation of responsibility

- HR owns workforce facts: identity, department, job title, worker type, manager, location and lifecycle event.
- IAM owns the translation from attributes to groups, licenses, access packages, reviews and policies.
- The automation identity applies only an approved plan and never invents business data.
- Reviewers approve a stable plan hash rather than an unbounded script execution.

## Scale model

- The workbook contains 20 reviewable synthetic identities across six departments, three locations, employees, contractors, managers, a pre-hire and a scheduled leaver.
- A deterministic generator produces 1,000 records with the same schema for performance and validation testing.
- The large dataset remains offline. The live tenant receives only the explicitly approved pilot subset.

## Pipeline gates

1. **Validate:** required schema, controlled values, unique Employee IDs, manager references, lifecycle consistency and alias format.
2. **Plan:** produce action counts and a sanitized record-level desired-state plan.
3. **Approve:** bind approval to the SHA-256 hash of the generated plan.
4. **Apply:** future Graph adapter creates, updates or disables only the approved records.
5. **Verify:** re-query Microsoft Entra ID and compare observed state with the approved desired state.
6. **Evidence:** store sanitized counts, test results and rollback outcome; never store passwords, tokens or live UPNs.

## Interview relevance

This pipeline addresses the scale question directly. An administrator does not edit a thousand identities or PIM assignments individually. The organization governs an authoritative source, validation rules, deterministic mappings, delegated ownership, approval gates and repeatable automation.

## Production limitations

- Excel is a lab representation of an HR source. Production should use an HRIS integration through SCIM, API-driven inbound provisioning or another governed connector.
- The current implementation stops before Graph writes. Workload identity, Graph permissions, retry behavior, idempotency and rollback execution require separate design and approval.
- Applying the full 1,000-record dataset to the lab tenant is explicitly out of scope.
