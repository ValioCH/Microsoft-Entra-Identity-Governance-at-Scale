# Environment Boundary

## Lab scope

This repository is scoped to the independent clean-room Microsoft tenant started on 2026-09-01. It is not the recovered historical tenant used by the earlier Sentinel and hybrid SOC portfolio project.

No historical screenshot, export, role assignment, policy or deployment verifies the state of this environment.

## Time-limited services

| Item | Recorded state | Status | Follow-up |
|---|---|---|---|
| Microsoft 365 E5 trial | Reported to expire 2026-10-01 | Owner-reported — pending verification | Recheck before implementation and cleanup |
| Azure promotional credit | Owner reports EUR 171.73 remaining and expiry on 2026-10-01 | Owner-reported — pending verification | Verify balance, expiry and eligible services in portal |
| Recurring billing | Previously observed as disabled | Owner-reported — pending current verification | Recheck before trial expiry |

## Sanitized identity labels

The following labels may be used in documentation without publishing operational identifiers:

- `daily-admin`
- `legacy-owner`
- `emergency-access-01`
- `emergency-access-02`
- `pilot-user-01`
- `pilot-user-02`

The existence, role, license and authentication readiness of any label must be independently verified for this project's evidence record before it is used as a deployment prerequisite.

## Initial restrictions

- No synchronization deployment is approved.
- No Conditional Access enforcement is approved.
- No role or PIM assignment change is approved.
- No access review or lifecycle workflow is approved.
- No paid Azure resource deployment is approved.
- Repository planning and read-only discovery remain separate from cloud application.

