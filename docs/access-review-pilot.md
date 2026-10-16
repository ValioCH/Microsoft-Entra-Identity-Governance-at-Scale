# Delegated Access Review Pilot

## Status

**Verified** under `EV-IG-008` on 2026-09-29 (Europe/Sofia).

## Objective

Validate delegated review of membership in the Tier 2 role-assignable group, including reviewer notification, an automated recommendation, a justified human decision, an audit trail and controlled retention of approved access.

## Implemented model

```text
Role-assignable Tier 2 group
        |
        v
One-time review of all members
        |
        v
Selected reviewer works in My Access
        |
        v
Automated recommendation + human decision + justification
        |
        v
Administrator observes result and validates retained membership
```

The pilot review was named `AR-PIM-T2-Groups-Admins-Pilot` and used reference `LAB-AR-001`.

## Controls

- Review scope limited to one privileged role-assignable group.
- All current group members included in scope.
- Selected reviewers rather than self-review.
- One-time, one-day pilot window.
- Justification, email notifications and reminders enabled.
- Thirty-day inactivity recommendation enabled as a decision helper.
- Automatic application disabled to preserve an administrative control point.
- No-change behavior selected when reviewers do not respond.

## Validation procedure

1. Create the one-time review for the Tier 2 role-assignable group.
2. Confirm the reviewer receives one pending review in Microsoft My Access.
3. Inspect the recommendation for the dedicated Tier 2 identity.
4. Compare the recommendation with current PIM and audited operational evidence.
5. Submit a justified human decision.
6. Verify the decision, reviewer and date in the administrative Results view.
7. Verify the successful `Approve decision` event and justification in audit logs.
8. Confirm that the approved Tier 2 identity remains a direct group member.

## Observed results

- The delegated task appeared in My Access for the selected reviewer.
- Entra recommended `Deny` because it classified the principal as an inactive user.
- The reviewer selected `Approved` after considering the current operational requirement and the completed PIM validation under `LAB-PIM-001`.
- The administrative Results view recorded `Approved`, the reviewer identity and the review date while retaining the original `Deny` recommendation.
- The access-review audit record showed a successful `Approve decision` event and retained the supplied justification.
- The Tier 2 identity remained the single direct member of the role-assignable group after the approved decision.

## Findings and limitations

- Recommendation data is advisory. In this pilot it did not reflect the recent privileged-access validation, so the human reviewer overrode it with documented evidence.
- Selecting two reviewers in a single stage provides alternative reviewers, not two-person approval. A production requirement for sequential approval should use a multi-stage review.
- The My Access portal is the reviewer workspace; the Entra admin center is the configuration, monitoring and evidence workspace.
- The available raw capture verifies the approved decision and retained membership. It does not independently expose a completed apply-result value, so no claim is made that a separate membership mutation occurred.
- The review covered one principal. Enterprise scale should use recurring reviews, group owners or scoped reviewers, escalation rules and operational ticket integration.
- Raw captures contain operational identifiers and remain excluded from Git until sanitized.

## Scale model

At scale, reviewers receive only the populations they govern, while the platform schedules recurrence, records decisions and applies configured outcomes. ServiceNow or another ITSM platform can provide ticket correlation and escalation, but it is an integration layer rather than a prerequisite for Entra access reviews.
