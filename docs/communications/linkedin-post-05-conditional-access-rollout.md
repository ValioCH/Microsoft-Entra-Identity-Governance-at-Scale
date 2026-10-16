# LinkedIn Post 05 — A controlled No-Go is a security result

## Publication draft

**Conditional Access should be deployed as a controlled change programme—not enabled tenant-wide because the policy syntax looks correct.**

For the final implementation milestone in this series, I prepared a narrow report-only MFA policy for the privileged pilot group.

The intended policy targeted all cloud resources, required multifactor authentication and excluded no ordinary administrators. Before creation, the Entra portal identified an important dependency: Security Defaults was still active and would need to be disabled before Conditional Access could take over.

I stopped and discarded the policy.

Disabling the existing baseline before replacement policies, recovery access and monitoring were ready would have increased risk. The correct result was **No-Go**, not “complete the lab at any cost.” Security Defaults remained unchanged and no live Conditional Access policy was created.

I then modeled the rollout architecture offline:

- Ring 0 — two emergency identities, excluded and monitored;
- Ring 1 — privileged pilot;
- Ring 2 — IT pilot;
- Ring 3 — HR and Finance;
- Ring 4 — broad workforce.

Each ring required at least 95% MFA readiness before promotion. Across 1,000 synthetic identities, the model found:

- 872 identities that would satisfy MFA;
- 98 requiring registration;
- 28 inactive identities not targeted;
- two protected emergency exclusions;
- zero of four rollout rings ready for promotion.

The simulation passed because it evaluated every identity, protected the exclusions and enforced the readiness gate. The deployment failed its gate—and was therefore blocked. A green script result is not permission to enforce a policy.

A production cutover would still require verified emergency access, replacement baseline policies, explicit change approval, What If analysis, report-only sign-in evidence, support readiness and a tested rollback path. Rings would be promoted one at a time only after the preceding evidence was accepted.

This milestone validated the rollout decision model, not live Conditional Access enforcement.

The larger lesson from the project is that identity governance at scale is built from boundaries: authoritative data, policy mapping, human approval, delegated ownership, readiness gates and evidence.

#MicrosoftEntra #ConditionalAccess #ZeroTrust #IAM #SC300 #CloudSecurity

## Evidence boundary

Supported by EV-IG-010. The live policy remained Planned and Security Defaults remained enabled.

## Recommended carousel

1. `visuals/post-05-conditional-access-rollout.png` — explanatory lead image.
2. Raw `2026-09-30/CA policy.png` — the strongest process screenshot because it records report-only intent and the Security Defaults dependency; verify that no tenant-specific browser chrome is visible.
3. Raw `2026-09-30/conditional-access/01-ca-scale-repeatability.png` — use a cropped derivative showing both result blocks; remove the local filesystem path and avoid presenting `PASS` as rollout approval.

