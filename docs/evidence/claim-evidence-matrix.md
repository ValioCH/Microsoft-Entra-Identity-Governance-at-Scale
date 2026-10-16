# Claim and Evidence Matrix

This matrix is the publication boundary for the portfolio. A claim may be described as implemented or verified only at the evidence level shown here.

| Portfolio claim | Status | Evidence | Safe public wording | Boundary |
|---|---|---|---|---|
| HR dataset and lifecycle plan scale to 1,000 identities | Verified | EV-IG-002 | Processed and validated 1,000 deterministic synthetic HR records | Not 1,000 live tenant users |
| Attribute-driven Joiner, Mover and Leaver behavior | Verified | EV-IG-003 | Validated a controlled two-identity JML pilot | Assigned legacy access required separate reconciliation |
| Idempotent live identity batch | Verified | EV-IG-004 | Created a controlled 10-identity batch and confirmed a zero-change second plan | Lab administrator used interactive delegated access |
| Group-based licensing and reclamation | Verified | EV-IG-005 | Demonstrated allocation on enable and reclamation on disable | Trial capacity and a small pilot population only |
| Department reconciliation | Verified | EV-IG-006 | Reconciled expected membership totals through Graph | Aggregate counts, not an enterprise directory |
| Group-based PIM and JIT administration | Verified | EV-IG-007 | Activated eligible group-based administration through MFA, justification, ticket and approval; audited the action and observed expiry | One Tier 2 identity and one role; no broad production rollout |
| Delegated access review | Verified | EV-IG-008 | Completed a reviewer task in My Access and recorded a justified human override of an automated recommendation | One live privileged identity |
| Access-review operating model at scale | Verified | EV-IG-009 | Executed deterministic reviewer allocation and recommendation logic across 1,000 synthetic identities | Simulation, not 1,000 licensed live reviews |
| Conditional Access controlled rollout | Verified design and simulation; live policy Planned | EV-IG-010 | Modeled five deployment rings and blocked promotion when readiness was below 95 percent | No live CA policy or enforcement; Security Defaults remained enabled |
| Administrative tiering | Planned model; Tier 2 slice Verified | EV-IG-007 | Designed Tier 0/1/2 separation and validated the Tier 2 pattern | Tier 0 and Tier 1 were not deployed |
| Emergency recovery | Planned | Runbook only | Designed two-path emergency recovery and cutover gates | Two-account recovery exercise not completed |
| Hybrid identity | Planned | ADR-001 | Documented source-of-authority and synchronization selection criteria | No live AD DS or synchronization deployment |
| Multi-tenant governance | Planned | Multi-tenant blueprint | Designed B2B trust, lifecycle and access-review boundaries | No second tenant or cross-tenant synchronization deployed |

## Prohibited claims

- Do not say that 1,000 live accounts were created, licensed or reviewed.
- Do not say Conditional Access was deployed or enabled.
- Do not say emergency recovery, hybrid synchronization or cross-tenant synchronization was verified.
- Do not describe the lab as production-ready or as a substitute for enterprise operating experience.
- Do not publish raw portal captures containing UPNs, IDs, billing identifiers or tenant-specific URLs.
