# Public Evidence Gallery

This directory contains sanitized artifacts selected for public portfolio use. Raw portal captures remain outside the Git publication boundary.

| Artifact | Evidence boundary |
|---|---|
| `01-identity-lifecycle-boundary.png` | Explains the 20-record review model, small live pilot and 1,000-record offline preflight. |
| `02-birthright-policy-mapping.png` | Shows the approved HR-to-birthright policy model; it does not grant privileged roles. |
| `03-department-reconciliation.png` | Shows sanitized aggregate membership counts after the controlled live batch. |
| `04-group-based-licensing.png` | Shows the small live pilot used to validate group-based license allocation. |
| `05-privileged-access-lifecycle.png` | Summarizes the verified Tier 2 PIM control cycle and its one-role boundary. |
| `06-pim-role-settings.png` | Shows the live MFA, justification, ticket, approval and activation-duration settings. |
| `07-active-to-expired.png` | Shows eligible access retained while the active assignment returned to zero after expiry. |
| `08-human-access-review.png` | Summarizes the live reviewer override of an automated recommendation. |
| `09-review-operating-model.png` | Summarizes the deterministic 1,000-identity reviewer-routing simulation. |
| `10-conditional-access-rollout.png` | Summarizes the rollout simulation and controlled decision not to create a live policy. |

These images support the repository narrative but do not replace the dated procedures and observed results in the [Evidence Register](../evidence-register.md).

## Publication controls

- No full UPNs, tenant domains, object IDs, correlation IDs, private URLs or local filesystem paths.
- Synthetic scale results are identified as simulations rather than live tenant deployment.
- Planned hybrid, multi-tenant, emergency-recovery and Conditional Access controls remain labelled as planned where applicable.
- Raw screenshots are excluded through `.gitignore`.
