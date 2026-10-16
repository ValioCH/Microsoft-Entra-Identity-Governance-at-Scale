# Access Review Scale Model

## Status

**Verified** under `EV-IG-009` on 2026-09-29 (Europe/Sofia).

## Purpose

The live pilot proves that Microsoft Entra can deliver a delegated review, present a recommendation, record a justified decision and preserve approved access. It does not prove an operating model for 1,000 identities.

The scale simulation closes that gap without creating unlicensed live identities. It processes the existing 1,000-record synthetic HR dataset, assigns review ownership, creates recommendations, isolates privileged exceptions and measures reviewer workload.

## Decision policy

| Condition | Recommendation |
|---|---|
| Disable action or scheduled leave | Deny |
| Privileged exception | ManualReview |
| Pre-hire status | ManualReview |
| Simulated inactivity over 30 days | Deny |
| Active lifecycle and recent activity | Approve |

Privileged exceptions take precedence over inactivity recommendations because the review requires additional operational evidence rather than an automatic decision.

## Reviewer allocation

Review ownership is divided by department and location. The simulation fails when any reviewer exceeds the configured workload ceiling. This demonstrates that scale is managed by distributing responsibility, not by assigning 1,000 decisions to one administrator.

## Execution

```powershell
./scripts/Invoke-AccessReviewScaleSimulation.ps1 `
  -InputPath ./outputs/scale/synthetic-hr-1000.csv `
  -MaximumReviewerLoad 100
```

Run the same command twice. Identical `InputSha256` and `PlanSha256` values demonstrate deterministic repeatability.

## Observed result

- Status: `PASS`
- Identities processed: 1,000
- Reviewers: 16
- Maximum reviewer workload: 81
- Average reviewer workload: 62.5
- Recommendations: 245 Approve, 726 Deny and 29 ManualReview
- Privileged exceptions routed to manual review: 10
- Reviewers exceeding the ceiling of 100: 0
- Second-run plan hash matched the first run

The large Deny population is expected from the deterministic inactivity distribution and is retained as test pressure on bulk-decision and exception-handling processes; it is not a forecast of a real workforce.

## Outputs

- `outputs/access-review-scale/access-review-decisions.csv`
- `outputs/access-review-scale/reviewer-workload.csv`
- `outputs/access-review-scale/access-review-plan.json`
- `outputs/access-review-scale/access-review-summary.json`

## Boundary

This is an executed operating-model simulation, not evidence that 1,000 licensed identities were governed in a production tenant. The live Entra pilot and the synthetic scale test provide complementary evidence.
