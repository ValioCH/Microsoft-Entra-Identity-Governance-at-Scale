# Birthright Access Model

## Status

**Configured locally** — the deterministic policy evaluator exists and has no connection to Microsoft Graph. Cloud groups, licenses and assignments remain **Planned** until separately approved and verified.

## Decision boundary

The HR source supplies workforce facts. IAM translates approved attributes into low-risk birthright access:

- active-workforce scope;
- department and location collaboration groups;
- employee or contractor governance scope;
- a license profile that is applied only to an approved live pilot.

HR attributes never grant Microsoft Entra administrative roles, Azure RBAC roles or PIM eligibility. Privileged access requires a separate identity, role owner approval, least-privilege selection and time-bound PIM activation.

## Lifecycle behavior

| HR state | Result |
|---|---|
| Active employee | Active-workforce, department, location and employee license-profile decisions |
| Active contractor | Active-workforce, contractor, department and location decisions; no employee license profile |
| Pre-hire | Pre-hire staging group only |
| Scheduled leaver / Disable | Remove all birthright access; downstream offboarding and session controls require a separate approved workflow |

## Scale and rollout

The evaluator runs against both the reviewable pilot file and the 1,000-record synthetic dataset. It produces a deterministic decision report before any tenant write. A production rollout would then use:

1. schema and data-quality validation;
2. entitlement calculation;
3. peer or owner approval bound to the plan hash;
4. a small live pilot;
5. reconciliation of desired and observed state;
6. controlled expansion and rollback monitoring.

## Interview relevance

This design avoids editing users one by one. It also prevents a common identity-governance failure: treating a job title or IT department value as sufficient authorization for privileged access.
