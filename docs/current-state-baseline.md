# Current-State Baseline

## Discovery record

- Date: 2026-09-23 (Europe/Sofia)
- Source: owner-operated Microsoft Entra and Microsoft 365 portal session
- Evidence handling: the supplied composite screenshot contains operational identifiers and billing data and is intentionally not retained in this repository
- Overall status: **Configured** — observed configuration only; control effectiveness has not yet been tested

## Tenant and capacity

| Area | Sanitized observation |
|---|---|
| Tenant country or region | Bulgaria |
| Primary data location | EU Model Clause compliant datacenters |
| Users | 6 |
| Groups | 4 |
| Microsoft 365 E5 trial | 25 seats; 2 assigned; 23 available |
| Trial renewal | Recurring billing off |
| Trial expiry | 2026-10-01 |
| Azure subscription | Usage-based Azure plan exists; cost and credit balance still require separate verification |

## Privileged access

| Observation | Status | Validation gap |
|---|---|---|
| Four active Global Administrator assignments are present | **Configured** | All four are permanent; confirm authentication readiness individually |
| Two assignments are intended as emergency-access identities | **Configured** | Independently test both recovery identities before changing privileged access |
| Two assignments are personal administrative identities | **Configured** | Determine which standing assignment can be converted to eligible access after recovery validation |
| Eligible Microsoft Entra role assignments | **Configured** | None are currently present |

No role change is approved by this discovery record.

### Recovery-readiness checkpoint

- `emergency-access-01`: Microsoft Authenticator is registered, usable, default and system-preferred. Interactive administrative access remains pending because the sign-in flow required passkey registration before the portal validation could be completed.
- `emergency-access-02`: authentication registration and interactive administrative access remain pending until the independent second device is available.
- Status remains **Configured**, not **Verified**. No standing privileged assignment will be removed until both paths are independently validated.

## Conditional Access

- Configured Conditional Access policies: 0
- Security Defaults: enabled
- No Conditional Access creation or enforcement is approved.

## Authentication methods

| Method | Target | Observed state |
|---|---|---|
| Passkey (FIDO2) | All users | Enabled |
| Microsoft Authenticator | All users | Enabled |
| Temporary Access Pass | All users | Enabled |
| Software OATH tokens | All users | Enabled |
| Email OTP | All users | Enabled |
| SMS | — | Disabled |
| Hardware OATH tokens | — | Disabled |
| Voice call | — | Disabled |
| Certificate-based authentication | — | Disabled |
| Verified ID | — | Disabled |
| QR code | — | Disabled |

Enabled policy state does not prove that each identity has registered or successfully tested the method.

## Existing groups

Four cloud groups exist:

- one assigned Microsoft 365 organization-wide group;
- one dynamic security group;
- one assigned security group;
- one assigned Microsoft 365 lab group.

Membership rules, owners, licensing and privileged use remain to be assessed before reuse.

## Project pilot boundary

`SG-PILOT-Identity-Governance` is **Verified** under `EV-IG-001` with exactly two sample identities, no directory roles and no licenses. It is the controlled target for subsequent non-privileged identity-governance tests.

## Immediate design implications

1. Security Defaults currently supplies the tenant-wide baseline. Do not disable it until replacement Conditional Access controls are designed, piloted and ready for an approved cutover.
2. Validate both emergency-access identities before reducing standing Global Administrator access.
3. Reuse existing groups only after ownership and membership-rule review.
4. Use a small pilot population; do not expand the tenant merely to imitate enterprise scale.
5. Verify Azure credit, current spend and residual-charge risk before any Azure deployment.
