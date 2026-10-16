# Enterprise Interview Requirements Traceability

This document connects enterprise interview gaps to project deliverables. It does not claim that portfolio work replaces production experience.

| Enterprise question | Project response | Evidence or boundary |
|---|---|---|
| How do you manage 1,000 identities? | Attribute-driven groups, parameterized automation, a 1,000-record synthetic preflight and a controlled 10-identity live batch | EV-IG-002, EV-IG-004 and EV-IG-006 |
| How do you recertify access across 1,000 identities? | Delegated reviewers, workload ceilings, deterministic recommendations and 10 privileged exceptions routed for manual review | EV-IG-008 and EV-IG-009; this is not a claim of 1,000 live administrators |
| How do you apply PIM at scale? | Role model, role-assignable groups, eligible group assignment and controlled activation | EV-IG-007 |
| How do you introduce policies safely? | Deployment rings, recovery exclusions, readiness thresholds and an explicit no-go gate | EV-IG-010; live report-only evaluation remains Planned |
| How do you manage multiple tenants and on-premises identities? | Authoritative-source ADR plus cross-tenant trust, lifecycle and review blueprint | Architecture decision; no live multi-tenant or hybrid deployment claimed |
| How do you structure privileged accounts? | Tier 0/1/2 separation, dedicated identities and group-based eligible access | Tiering model and EV-IG-007 Tier 2 pilot |
| How do you protect emergency access? | Two independent cloud-only identities, exclusions, monitoring and recovery runbook | Architecture is Planned; two-account recovery validation remains an explicit gate |
| How should HR-driven provisioning work? | SCIM or API-driven production design, validated in the lab through HR attributes, deterministic planning, dynamic groups and group-based licensing | EV-IG-003, EV-IG-004 and EV-IG-005 |
| How do you automate safely? | Preview mode, stable plan hash, explicit approval, idempotency verification, reconciliation and rollback | EV-IG-002 and EV-IG-004; workload identity remains a production-design limitation |
