# LinkedIn Post 04 — Access reviews without a 1,000-item central queue

## Publication draft

**The scale problem in access reviews is not generating 1,000 decisions. It is assigning accountable ownership without overwhelming reviewers.**

The previous milestone validated one real delegated review in Microsoft Entra. The next step was an offline operating-model simulation using the same 1,000-record synthetic workforce dataset.

Before running it, I defined the decision and routing policy:

- scheduled leaver or Disable action → Deny;
- simulated inactivity over 30 days → Deny;
- pre-hire → Manual Review;
- privileged exception → Manual Review, regardless of inactivity;
- active lifecycle with recent activity → Approve.

Review ownership was then partitioned by department and location rather than sent to a single IAM queue. A reviewer-load ceiling of 100 items was a blocking gate.

Observed result:

- 1,000 identities allocated exactly once;
- 16 reviewer queues;
- maximum queue size: 81;
- average queue size: 62.5;
- 245 Approve recommendations;
- 726 Deny recommendations;
- 29 Manual Review cases;
- 10 privileged exceptions isolated for manual handling;
- zero reviewers above the threshold;
- identical plan hash on the second run.

The large Deny count is synthetic test pressure created by the deterministic inactivity model. It is not a forecast about a real company.

The purpose of the exercise was to test control invariants: complete population coverage, one accountable queue per identity, bounded reviewer load, precedence for privileged exceptions and repeatable output.

In production, Entra would schedule the reviews and capture decisions. Group owners, managers or application owners would receive scoped populations, while ITSM integration could provide escalation and ticket correlation. Reviewer capacity and unresolved decisions would need operational monitoring.

This simulation does not prove that 1,000 live Entra users were reviewed. Combined with the one-user live pilot, it demonstrates the difference between validating product behavior and testing an operating model.

Next: why a successful Conditional Access script can still produce the correct decision **not to deploy**.

#MicrosoftEntra #AccessReviews #IAM #IdentityGovernance #Automation

## Evidence boundary

Supported by EV-IG-009. The recommendations are synthetic and were not applied to live memberships.

## Recommended carousel

1. `visuals/post-04-review-operating-model.png` — explanatory lead image.
2. Raw `2026-09-29/access-review-scale/01-repeatable-1000-identity-run.png` — use a cropped derivative showing both result blocks and matching plan hashes; remove the local filesystem path.

