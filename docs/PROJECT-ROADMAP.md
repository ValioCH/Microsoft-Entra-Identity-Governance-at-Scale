# Project Roadmap — Enterprise Identity Governance at Scale

## Target architecture

```text
[ HR / Authoritative Source ]          [ On-premises AD ]
               │                              │
               └──────────┬───────────────────┘
                          ▼
             [ SCIM / API / Hybrid Sync ]
                          │
                          ▼
                [ Microsoft Entra ID ]
        Attributes • Dynamic Groups • Admin Units
                          │
              ┌───────────┴────────────┐
              ▼                        ▼
 [ Identity Governance ]         [ Access Control ]
 PIM • Access Reviews • JML      CA Rings • Auth Strengths
 Role-assignable Groups          Emergency Access • Tiering
              └───────────┬────────────┘
                          ▼
              [ Monitoring & Evidence ]
        Sign-in Logs • Audit Logs • Validation

Across every layer:
Microsoft Graph + PowerShell → Dry Run → Human Approval → Rollback
```

## Nine-day execution plan

The plan prioritizes capabilities included in the time-limited Microsoft 365 E5 trial. Every material cloud change requires separate approval after scope, permissions, risk, cost, validation and rollback are presented.

### Phase 1 — Foundation and verified discovery (Days 1–2)

- Establish the separate repository, evidence model and environment boundary.
- Record the hybrid identity architecture decision: Connect Sync versus Cloud Sync and the selected authentication model.
- Run read-only discovery of licenses, trial expiry, administrative roles, authentication methods, groups and existing policies.
- Verify the current Azure credit and confirm that no recurring or residual cost is being introduced.
- Build the sanitized identity and role model using aliases only.
- Define the administrative tiers:
  - Tier 0: identity and control plane;
  - Tier 1: servers and applications;
  - Tier 2: endpoints and user support.

**Deliverables:** repository foundation, ADR-001, current-state inventory, tiering model and evidence plan.

### Phase 2 — Identity lifecycle and synthetic scale (Days 3–4)

- Define the authoritative HR attributes required for joiner, mover and leaver processing.
- Create a local synthetic dataset representing approximately 1,000 identities; do not create 1,000 live accounts.
- Build parameterized Graph/PowerShell automation with:
  - validation of required attributes;
  - preview/dry-run mode;
  - deterministic department and location mapping;
  - structured success and error output;
  - no credentials embedded in code.
- Use only a few live pilot identities after approval to validate create, update, disable and reconciliation behavior.
- Design dynamic groups, administrative units and group-based licensing from trusted attributes.

**Deliverables:** synthetic dataset, dry-run report, tested pilot workflow and JML decision record.

### Phase 3 — Privileged access and emergency recovery (Days 5–6)

- Design separate daily and privileged administrative identities.
- Map roles to administrative tiers and eliminate unnecessary Global Administrator use in the target design.
- Design role-assignable groups to avoid hundreds of individual privileged assignments.
- Configure one limited PIM pilot after approval:
  - eligible rather than permanently active assignment;
  - maximum two-hour activation;
  - MFA and justification;
  - approval only where operationally justified;
  - activation and expiration evidence.
- Validate the two emergency-access identities independently before changing routine privileged assignments.
- Confirm that emergency identities are excluded from routine automation and future restrictive Conditional Access policies.

**Deliverables:** privileged-role matrix, PIM pilot evidence, emergency-access test records and recovery runbook.

### Phase 4 — Delegated governance and safe policy rollout (Days 7–8)

- Design an access-review model that delegates decisions to managers, role owners or resource owners instead of one central reviewer.
- Pilot one narrowly scoped access review with explicit nonresponse behavior and protected exclusions.
- Define Conditional Access deployment rings:
  1. report-only;
  2. test identities;
  3. pilot department;
  4. broader population;
  5. organization-wide enforcement only after validation.
- Create or evaluate one report-only Conditional Access pilot after approval.
- Use What If and sign-in evaluation, capture exclusions and define rollback.
- Document the multi-tenant and B2B/cross-tenant design without deploying unnecessary additional tenants.

**Deliverables:** delegated review design, access-review pilot, CA policy export, What If result, rollout decision and multi-tenant blueprint.

### Phase 5 — Validation, cleanup and portfolio packaging (Day 9 / before trial expiry)

- Run repository privacy, secret and identifier checks.
- Reconcile every claim with the evidence register and status vocabulary.
- Record which controls are Planned, Configured and Verified.
- Check license expiry, recurring billing, Azure credit and residual billable resources.
- Disable or clean up approved temporary test configuration where required; deletion requires separate approval.
- Finalize:
  - README;
  - architecture diagram;
  - ADRs;
  - scripts and tests;
  - sanitized evidence;
  - production limitations;
  - interview-requirements traceability.

**Deliverables:** reviewable portfolio release candidate and final project milestone post based only on verified work.

## Interview questions answered by the project

| Interview theme | Demonstrated answer |
|---|---|
| Thousands of identities | Synthetic dataset, parameterized automation and limited live pilot |
| Thousands of administrators | Role rationalization, role groups and delegated reviewers |
| PIM at scale | Group-based eligible access and automated assignment design |
| Safe policy changes | Report-only, What If, deployment rings, monitoring and rollback |
| Multi-tenant and hybrid identity | Authoritative-source ADR, sync decision and cross-tenant blueprint |
| Administrative tiers | Separate Tier 0/1/2 identities and sign-in boundaries |
| HR-driven provisioning | SCIM/API JML design with least-privileged workload identity |
| Production readiness | Approval gates, evidence, negative tests, exception handling and cleanup |

## Out of scope before 2026-10-01

- Creating 1,000 live users.
- Building an unnecessary on-premises forest solely for visual completeness.
- Deploying additional production-like tenants.
- Tenant-wide Conditional Access enforcement.
- Removing all standing Global Administrator access before recovery is independently tested.
- Sentinel, Defender, SOAR or unrelated endpoint expansion.
- Claiming that a successful lab pilot proves enterprise production readiness.

