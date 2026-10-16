# Privileged Access Pilot

## Status

**Verified** under `EV-IG-007` on 2026-09-29 (Europe/Sofia).

## Objective

Validate a scalable Microsoft Entra privileged-access pattern without assigning an administrative role directly to each person.

## Implemented model

```text
Dedicated Tier 2 identity
        |
        v
Assigned membership in a role-assignable group
        |
        v
Eligible Groups Administrator assignment
        |
        v
MFA + justification + ticket + independent approval
        |
        v
One-hour active role -> controlled action -> audit -> rollback -> expiration
```

The role policy allows a maximum two-hour activation. The validation request used one hour because the approved task required less time.

## Controls

- Separate daily and privileged identities.
- No standing active `Groups Administrator` role.
- Role assigned to a protected role-assignable group rather than directly to a user.
- Assigned group membership; dynamic membership is prohibited for role-assignable groups.
- MFA, justification, ticket information and approval required on activation.
- Permanent eligible assignment allowed; permanent active assignment prohibited.
- Active assignments require MFA and justification and expire after at most one month when directly assigned.
- Two independent approvers configured.
- Licensing and authorization kept in separate groups.

## Validation procedure

1. Confirm the Tier 2 identity has an eligible role and no active assignment.
2. Request one-hour activation using ticket `LAB-PIM-001`.
3. Approve the request from a separate identity.
4. Confirm `Groups Administrator` is active with a defined end time.
5. Add the Tier 2 identity temporarily to the non-privileged pilot group.
6. Verify the directory audit record identifies the Tier 2 identity as actor.
7. Remove the temporary membership from the Tier 2 session.
8. Verify the successful removal in directory audit logs.
9. Allow the PIM activation to expire without manual deactivation.
10. Confirm Active assignments is empty and the eligible assignment remains.

## Observed results

- The request entered the approval queue and included the approved ticket and justification.
- A separate approver approved the activation.
- The role became active for the approved time window.
- The Tier 2 identity successfully changed ordinary group membership.
- `Groups Administrator` did not provide access to the required audit-log view; a separate administrative identity performed audit verification. This preserved separation of duties.
- Both the add and rollback operations succeeded and recorded the Tier 2 identity as actor.
- The active role expired automatically and returned to eligible-only state.

## Findings and limitations

- The portal displayed an `Unknown error` toast while simultaneously creating a valid pending request. The request state, not the transient toast, was treated as authoritative after verification.
- Parallel operator and approver browser sessions can cause actions to be performed under the wrong identity. The test was repeated after checking the signed-in identity, and only the valid Tier 2 audit record is used as evidence.
- The tenant-wide `Groups Administrator` role is broad. A production design should evaluate administrative-unit scope or a custom role and split functional groups by geography or responsibility.
- The privileged identity currently consumes a Microsoft 365 E5 trial entitlement. A production design should use an appropriate Entra license SKU or disable unrelated service plans.
- Raw captures contain operational identifiers and remain excluded from Git until sanitized.

## Scale model

Assigned membership does not require manual portal administration. At scale, an approved IAM workflow can use Microsoft Graph to reconcile explicit membership from a governed role catalog. This avoids attribute-based automatic privilege escalation while eliminating individual role assignments and repetitive clicks.
