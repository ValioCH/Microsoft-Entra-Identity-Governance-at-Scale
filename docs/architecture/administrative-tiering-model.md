# Administrative Tiering Model

## Status

The enterprise model is **Planned**. Its Tier 2 slice is **Verified** under `EV-IG-007`: a separate Tier 2 identity received eligible `Groups Administrator` access through a role-assignable group, activated it through PIM and returned to eligible-only state after expiration.

## Objective

Separate identity-control-plane administration from ordinary cloud administration and daily productivity. The model reduces credential crossover and limits the impact of a compromised daily account.

## Proposed tiers

| Tier | Scope | Example responsibilities | Identity rule |
|---|---|---|---|
| Tier 0 | Identity control plane and recovery | Global Administrator, Privileged Role Administrator, Conditional Access administration, emergency recovery | Dedicated cloud administrative identity; no email or routine productivity use |
| Tier 1 | Azure and security platform administration | Subscription/resource administration, Sentinel, Defender and workload control planes | Dedicated administrative identity separated from daily work |
| Tier 2 | User, device and support operations | Help desk, user lifecycle, endpoint support and limited group administration | Scoped delegated identity; no Tier 0 privileges |
| Standard | Productivity and collaboration | Email, Teams, browsing and ordinary business applications | No privileged directory role |

## Role and control matrix

| Tier | Example roles | Activation model | Approval and evidence | Prohibited crossover |
|---|---|---|---|---|
| Tier 0 | Global Administrator, Privileged Role Administrator, Conditional Access Administrator | Permanent only for two recovery exceptions; eligible PIM for routine operators | Phishing-resistant MFA, justification, approval for high-impact roles, complete audit | Email, browsing and endpoint support from the privileged identity |
| Tier 1 | Azure subscription roles, Security Administrator, Sentinel roles, application platform administration | Eligible or time-bound assignment at the narrowest resource scope | MFA, ticket, workload owner approval and resource audit | Identity-control-plane administration unless separately authorized |
| Tier 2 | Groups Administrator, User Administrator, Authentication Administrator or scoped custom role | Eligible group-based or direct PIM assignment | MFA, justification, approval where independent operations permit | Tier 0 policy, role and recovery administration |
| Standard | None | Not applicable | Normal access governance | Any privileged role assignment |

## Emergency-access identities

- Two cloud-only recovery identities remain outside routine administration.
- They are not members of operational role groups and are not used for daily work.
- Their authentication paths must be independent and tested separately.
- Every sign-in must be monitored once the monitoring phase is implemented.
- They remain permanent Global Administrators only as an explicitly documented recovery exception.

## Target privileged model

- Routine privileged access is eligible rather than permanently active.
- Activation duration is task-based, with a two-hour maximum used as the initial lab target.
- MFA and justification are required for activation.
- Approval is applied to high-impact roles where a viable independent approver exists.
- Role-assignable groups are used only when group-based role governance is justified and tested.
- No personal daily identity receives standing Global Administrator access.

## Safe migration order

1. Validate both emergency-access identities independently.
2. Confirm audit visibility for emergency and privileged sign-ins.
3. Create a non-privileged pilot group and validate membership governance.
4. Configure one low-impact eligible PIM pilot.
5. Validate activation, expiration and recovery.
6. Only then consider converting a standing personal Global Administrator assignment.

## Rollback principle

Do not remove the last known-good administrative path. A failed pilot is rolled back by removing the pilot assignment or group membership while the validated recovery identities remain available.

## Scale and ownership

Role-assignable groups use explicit assigned membership. At scale, membership is reconciled from an approved role catalog through Microsoft Graph rather than made dynamic. Functional groups are divided by tier, responsibility and scope; access reviews recertify membership, and PIM controls activation. This avoids both hundreds of direct role assignments and attribute-driven privilege escalation.
