# Multi-Tenant and B2B Identity Blueprint

## Status

**Planned** architecture decision. No additional tenant, cross-tenant synchronization or trust setting was deployed for this lab.

## Objective

Allow controlled collaboration across tenant boundaries without copying broad privileges, weakening authentication requirements or leaving unmanaged external identities indefinitely.

## Trust model

```text
Partner home tenant
  authenticates and manages source identity
             |
             v
Cross-tenant access settings
  inbound trust + application scope + user/group scope
             |
             v
Resource tenant
  guest or synchronized B2B identity
  access package / group / application assignment
  Conditional Access + access review + audit
```

The resource tenant remains authoritative for authorization. The home tenant may provide authentication claims only when an explicit inbound trust decision accepts them.

## Pattern selection

| Requirement | Preferred pattern |
|---|---|
| Occasional external collaboration | B2B invitation with scoped application or group access |
| Governed request, approval and expiration | Entitlement-management access package |
| Recurring workforce collaboration at scale | Cross-tenant synchronization with explicit attribute and population scope |
| Shared Microsoft 365 collaboration | B2B direct connect only after channel and trust requirements are documented |
| Administrative access | Dedicated privileged identity in the resource tenant; never inherit broad external privilege automatically |

## Inbound controls

- Default deny outside approved partner organizations, applications and populations.
- Trust partner MFA or device claims only after assurance, lifecycle and incident-response responsibilities are contractually understood.
- Apply resource-tenant Conditional Access when external claims are not trusted or are insufficient.
- Prohibit external identities from privileged groups unless an exceptional, time-bound and monitored design is approved.

## Lifecycle and reviews

- Record a sponsor, business owner, purpose and expiry for every external assignment.
- Use access packages or governed groups rather than direct application assignments where practical.
- Review high-risk access more frequently than ordinary collaboration.
- Remove resource access on denial or expiration; remove the guest object only after confirming it has no other governed assignment.
- Reconcile orphaned guests, missing sponsors and inactive partner organizations.

## Scale model

At enterprise scale, partner populations are partitioned by organization, resource owner and access package. Automation exports assignments, sponsors, expiry and review state through Microsoft Graph, while human reviewers decide exceptions. The same plan/hash/approval pattern used by the lab's 1,000-record simulations applies to cross-tenant reconciliation.

## Validation before production

1. Test with one partner tenant, one application and a small pilot group.
2. Verify authentication, consent, Conditional Access evaluation and sign-in logging.
3. Validate join, attribute update, disable and deletion behavior.
4. Test access-review denial and expiration cleanup.
5. Confirm emergency revocation without affecting unrelated partner access.

## Limitations

The lab supplies an architecture blueprint, not a live multi-tenant deployment. It does not demonstrate partner contractual assurance, cross-tenant synchronization throughput or production incident coordination.
