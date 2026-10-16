# LinkedIn Post 03 — Recommendation is not authorization

## Publication draft

**An automated recommendation can inform an access decision. It should not replace accountability.**

After validating time-bound PIM activation, I created a delegated access review for the Tier 2 role-assignable group.

The design separated three responsibilities:

- the Entra administrator configured and monitored the review;
- a selected reviewer completed the task in Microsoft My Access;
- audit evidence recorded the reviewer, decision and justification.

The review included all current members of the privileged group, required justification, enabled notifications and reminders, and used 30 days without sign-in as a decision helper. Automatic result application was disabled for the pilot so that the final control point remained visible.

Entra recommended **Deny** for the Tier 2 identity because it appeared inactive.

The reviewer did not accept the recommendation blindly. Recent PIM activation evidence showed a legitimate operational requirement, so the reviewer selected **Approve** and documented the reason. The Results view retained both facts: the automated Deny recommendation and the justified Approved decision. The approval event was also present in the audit log.

That difference matters. Inactivity is a useful signal, but it does not understand every business context. A mature review process combines signals with accountable human judgment—especially for privileged access.

The pilot also clarified two product behaviors:

- My Access is the reviewer workspace; the Entra admin center is the configuration and monitoring workspace.
- Two reviewers in one stage are alternatives, not sequential two-person approval. A true four-eyes requirement needs a multi-stage review.

This was a live review of one privileged identity. It proves task delivery, recommendation visibility, justified decision and auditability. It does not prove that one reviewer can govern an enterprise population.

That creates the next question: how should 1,000 decisions be divided so that no central administrator becomes the bottleneck?

#MicrosoftEntra #AccessReviews #IdentityGovernance #IAM #SC300

## Evidence boundary

Supported by EV-IG-008. No claim is made that a separate membership mutation occurred after applying the review result.

## Recommended carousel

1. `visuals/post-03-human-access-review.png` — explanatory lead image.
2. Raw `2026-09-29/access-review/access review - active - deny recommendation.png` — demonstrates the advisory Deny recommendation; redact reviewer and principal UPNs.
3. Raw `2026-09-29/access-review/access review - active - approved.png` — demonstrates the justified human outcome; redact reviewer and principal UPNs.

