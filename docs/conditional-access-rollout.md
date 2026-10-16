# Conditional Access Deployment Rings

## Status

The deployment design and deterministic impact simulation are **Verified** under `EV-IG-010` on 2026-09-30 (Europe/Sofia). The live report-only policy remains **Planned** and was not created.

## Tenant decision

On 2026-09-30 the approved policy `CA-RO-R1-Privileged-Admins-MFA` was prepared with these settings:

- include the Tier 2 privileged-administrator group;
- target all resources;
- require the built-in multifactor authentication strength;
- report-only state;
- no additional conditions or session controls.

The portal identified Security Defaults as an active dependency that must be disabled before Conditional Access can be enabled. The policy was discarded. Security Defaults remained enabled because a report-only policy would not replace its enforcement and the recovery prerequisites for a safe cutover were not complete.

This is a controlled **No-Go** decision, not a failed deployment.

## Deployment rings

| Ring | Population | Purpose | Promotion gate |
|---|---|---|---|
| Ring 0 | Emergency identities | Exclusion and monitoring | Exactly two protected recovery identities; never used for routine work |
| Ring 1 | Privileged pilot | Validate strong authentication for administrators | Recovery path validated; MFA readiness at least 95%; What If and report-only evidence |
| Ring 2 | IT pilot | Validate help-desk impact and registration remediation | Ring 1 stable; support and rollback ready |
| Ring 3 | HR and Finance | Controlled department rollout | Pilot findings resolved; business owners approve |
| Ring 4 | Broad workforce | Organization-wide coverage | Prior rings stable; exceptions documented; monitoring active |

## Synthetic impact model

The existing 1,000-record HR dataset is assigned deterministically to the five rings. The simulation models MFA readiness, inactive identities, two emergency exclusions and privileged identities. A ring receives `NoGo-RemediateMFA` when readiness is below 95 percent.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\Invoke-ConditionalAccessScaleSimulation.ps1 `
  -InputPath .\outputs\scale\synthetic-hr-1000.csv `
  -OutputDirectory .\outputs\conditional-access-scale `
  -MinimumMfaReadinessPercent 95
```

Run twice and compare `PlanSha256` to verify deterministic behavior.

## Observed simulation result

- Status: `PASS`
- Identities evaluated: 1,000
- Emergency exclusions: 2
- Privileged identities: 10
- Would satisfy MFA: 872
- User action required to register MFA: 98
- Inactive identities not targeted: 28
- Rings meeting the 95 percent promotion gate: 0
- Rings blocked pending remediation: 4
- Second-run plan hash matched the first run

The result is intentionally a `No-Go` for enforcement. The simulation itself passed its invariants, while every deployment ring failed the readiness gate. This distinction prevents a successful script run from being mistaken for approval to deploy.

## Intended live validation sequence

1. Verify the recovery identities and current Security Defaults state.
2. Prepare replacement baseline policies without enabling them.
3. Obtain explicit approval for the cutover window.
4. Disable Security Defaults and immediately activate the approved replacement baseline.
5. Keep expansion controls in report-only.
6. Run What If for privileged, ordinary and emergency identities.
7. Review sign-in report-only results and remediate registration gaps.
8. Promote one ring at a time only after its gate passes.

## Rollback

- Return the new policy to `Report-only` or `Off`.
- Restore the previously documented baseline when compatible.
- Use the independently validated emergency path if normal administration is blocked.
- Record the rollback actor, time, reason and observed access result.

No enforcement, Security Defaults change or live rollback occurred in this milestone.
