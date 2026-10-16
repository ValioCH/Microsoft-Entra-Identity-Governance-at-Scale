# LinkedIn Post 02 — Privilege is a separate lifecycle

## Publication draft

**Being in IT should not automatically make someone an administrator.**

That separation became the second control in my Enterprise Identity Governance at Scale lab.

The HR-driven model from the first milestone can assign low-risk birthright access: workforce, department, location and licensing groups. It cannot assign an Entra administrative role. Privilege requires a different identity, a different approval path and a limited activation window.

The Tier 2 pilot used this design:

**Dedicated admin identity → role-assignable group → eligible Groups Administrator role → PIM activation → audited task → automatic expiry**

The account had no standing active role. To activate it, the operator had to provide:

- Azure MFA;
- a justification;
- ticket information;
- approval from a separate approver.

For the validation, I requested one hour of access, performed a controlled group-membership change, verified the actor in the audit log, reversed the test change and allowed the role to expire. Afterwards, the active assignment was gone while eligibility remained.

Assigning the role to a protected group instead of directly to every administrator is the scalable part of the design. People can be reconciled against an approved role catalog while the role policy is managed once. The group uses explicit membership—dynamic rules are intentionally not used for privileged elevation.

The pilot also exposed two useful operational details:

- `Groups Administrator` could perform the scoped group task but could not access the required audit view, so verification used a separate identity. That preserved separation of duties.
- A portal error toast appeared even though the request had entered the approval queue. The verified request state, not the transient message, was treated as authoritative.

This was one role, one Tier 2 identity and one controlled task. It does not prove an enterprise PIM rollout. It validates the pattern: no standing privilege, explicit eligibility, independent approval, bounded activation, audit and expiry.

Next: what happens when an automated access-review recommendation is wrong.

#MicrosoftEntra #PIM #PrivilegedAccess #IAM #SC300 #ZeroTrust

## Evidence boundary

Supported by EV-IG-007. Tier 0 and Tier 1 remain architectural designs, not deployed controls.

## Recommended carousel

1. `visuals/post-02-privileged-access.png` — explanatory lead image.
2. Raw `2026-09-29/pim/05-active-assignment.png` — active, time-bounded role; safe after checking the top account bar.
3. Raw `2026-09-29/pim/08-expired-eligible-only.png` — before/after expiry; redact the signed-in UPN in both panels.

Do not publish `07-audit-actor-tier2.png` as-is: it contains a full UPN and operational audit identifiers. A sanitized crop may be used later.

