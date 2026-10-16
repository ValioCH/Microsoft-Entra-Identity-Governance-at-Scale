# LinkedIn Series Publication Plan

## Story

The series answers one interview-level question across five controls:

> How would identity governance be designed so that adding users does not add the same amount of manual administration and risk?

The narrative is:

1. authoritative HR facts are translated into low-risk birthright access;
2. privileged access is kept outside that automatic path;
3. automated signals inform, but do not replace, accountable review;
4. review ownership and workload are partitioned at scale;
5. enforcement expands only when recovery and readiness gates pass.

## Visual pattern

Every post uses the same three-layer evidence pattern:

1. **Lead diagram** — explains the intended control and the evidence boundary.
2. **Live process screenshot** — demonstrates actual Entra behavior where live validation exists.
3. **Scale or state evidence** — demonstrates deterministic offline behavior or a before/after state without implying production deployment.

## Screenshot selection

| Post | Lead visual | Supporting process evidence | Publication action |
|---|---|---|---|
| 1 | `visuals/post-01-hr-to-birthright-access.png` | IAM mapping preview; zero-change rerun | Mapping is publishable; redact tenant domain from terminal capture |
| 2 | `visuals/post-02-privileged-access.png` | Active assignment; eligible-only state after expiry | Redact signed-in UPN; do not publish raw audit-detail view |
| 3 | `visuals/post-03-human-access-review.png` | Deny recommendation; Approved decision | Redact principal and reviewer UPNs |
| 4 | `visuals/post-04-review-operating-model.png` | Two matching 1,000-record simulation runs | Crop to results; remove local filesystem path |
| 5 | `visuals/post-05-conditional-access-rollout.png` | Report-only policy dependency; two matching impact runs | CA screen is usable after chrome check; crop terminal path |

## Editorial rules

- Do not publish all five posts at once. Keep the completed drafts ready, then publish in sequence.
- Use the lead diagram first so a non-specialist can understand the screenshot that follows.
- Never describe an offline scale test as tenant-scale deployment.
- Never publish full UPNs, tenant domains, object or correlation IDs, local paths, tokens or billing identifiers.
- Keep the technical detail in the post body; do not turn the image into a wall of text.
- Answer comments with the same claim boundary used in the Evidence Register.

## Recommended cadence

Publish one implementation post every three to five business days. This leaves time to answer comments and prevents the five milestones from competing with each other in the same feed window.
