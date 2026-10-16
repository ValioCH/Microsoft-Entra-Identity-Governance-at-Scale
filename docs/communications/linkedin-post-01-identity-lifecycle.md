# LinkedIn Post 01 — From HR facts to governed birthright access

## Publication draft

**How do you stop identity lifecycle management from becoming 1,000 manual tickets?**

I started the implementation phase of my Enterprise Identity Governance at Scale lab with the source of the lifecycle: HR data.

The design decision came before the automation:

**HR owns workforce facts. IAM owns access policy.**

The simulated HR source supplies employee ID, department, worker type, manager, location, employment status and lifecycle action. IAM then translates only approved attributes into low-risk birthright access.

Examples from the lab policy:

- `Active LAB workforce` → active-workforce group and pilot group-based E5 licensing;
- `Employee / Contractor` → separate workforce governance decisions;
- `Department = Finance` → Finance collaboration group;
- `Location = Sofia` → Sofia location group;
- `PreHire` → staging access only;
- `LeaveScheduled / Disable` → remove calculated birthright access and flag residual assigned access for reconciliation.

An HR attribute never grants an administrative role. Privileged access is handled separately through PIM.

I validated the design at three different levels:

1. A 20-record synthetic HR workbook made the source data and IAM mappings reviewable.
2. A two-identity live Joiner/Mover/Leaver test and a separate 10-identity Entra batch validated attribute updates, dynamic membership, group-based licensing and a zero-change second plan.

The live pilot used seats from a 25-user Microsoft 365 E5 trial. This was lab capacity—not a recommendation that every production user should receive E5. In a real organization, license profiles should follow role requirements, service-plan needs and cost governance.

3. A deterministic 1,000-record dataset validated schema checks, controlled values, unique IDs, manager references and change-plan generation: 915 creates, 57 updates and 28 disables, with zero validation errors.

The 1,000 records were not provisioned into Entra. This was an offline preflight and policy test—not a claim of production-scale operation. A production implementation would normally connect an HRIS through governed inbound provisioning, SCIM or an API, then add retry, throttling, reconciliation and rollback controls.

The important result is not “a script processed 1,000 rows.” It is that workforce facts, access policy, approval, application and verification were designed as separate control points.

Next: why department membership must never automatically create an administrator.

#MicrosoftEntra #IdentityGovernance #IAM #SC300 #PowerShell #ZeroTrust

## Evidence boundary

Public claims are supported by EV-IG-002 through EV-IG-006. The visual intentionally distinguishes reviewable input, live validation and offline scale testing.

## Recommended carousel

1. `visuals/post-01-hr-to-birthright-access.png` — explanatory lead image.
2. `ready-to-publish/post-01/02-birthright-policy-mapping.png` — publication-safe mapping of HR facts to the controls actually validated or modeled.
3. Raw `2026-09-28/PS - user provisioning second time - no changes3.png` — use only after replacing the tenant domain with a neutral alias and cropping unrelated shell context.
