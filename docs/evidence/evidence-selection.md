# Evidence Selection and Sanitization Plan

Raw captures remain in `evidence-raw/` and are excluded from Git. This document lists the smallest useful public evidence set; it does not make the raw files publishable.

| Story | Preferred raw source | Public artifact to create | Required sanitization |
|---|---|---|---|
| Live batch planning and apply | `2026-09-28/PS - user provisioning success.png` | Cropped plan/apply summary | Remove tenant domain, account prompts, paths and identifiers |
| Idempotent second run | `2026-09-28/PS - user provisioning second time - no changes.png` | Zero-change verification panel | Remove tenant domain and shell history outside the result |
| JML lifecycle | Chris job/group captures | Three-panel Joiner/Mover/Leaver comparison | Replace names and UPNs with aliases; remove tenant navigation details |
| License reclamation | Active-license and disabled-no-license captures | Before/after allocation summary | Hide personal names, subscription details and tenant branding |
| PIM activation | `2026-09-29/pim/05-active-assignment.png` | Active role with bounded end time | Hide UPN, object identifiers and tenant name |
| PIM audit and expiry | `07-audit-actor-tier2.png`, `08-expired-eligible-only.png` | Actor/audit plus eligible-only state | Replace actor with `Tier2-Admin`; hide correlation and object IDs |
| Human-in-the-loop review | Access-review Deny and Approved captures | Side-by-side recommendation versus decision | Replace reviewer and principal names; hide UPNs |
| Review decision audit | `access-review/audit log.png` | Decision, status and sanitized justification | Remove actor UPN, correlation ID, IP and unrelated events |
| 1,000-identity review scale | User PowerShell repeatability capture | Two-run PASS and matching hash | Retain aggregate counts; crop local user path if desired |
| Conditional Access rings | User PowerShell repeatability capture | Two-run PASS, readiness and matching hash | Retain aggregate counts; remove local user path if present |
| Architecture | Planned architecture SVG | Public diagram | Confirm aliases only and label planned versus verified components |

## Selection rules

- Prefer aggregate outputs and diagrams over portal screenshots.
- Use one image to prove one claim.
- Preserve the original raw file; sanitize a copy.
- Cropping is insufficient when hidden metadata or adjacent content contains restricted data.
- Record the sanitized output path in the evidence register before publication.

## Pending inputs

- The final Access Review scale screenshot is retained under `evidence-raw/2026-09-29/access-review-scale/`.
- The final Conditional Access scale screenshot is retained under `evidence-raw/2026-09-30/conditional-access/`.
- Select no more than 6–10 public images for the complete repository.
