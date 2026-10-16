# Emergency Access and Recovery Runbook

## Status

**Planned** architecture. The repository records no completed two-account recovery exercise, so this document does not claim the recovery control is Verified.

## Purpose

Preserve an independent administrative path when routine authentication, Conditional Access, federation, synchronization or privileged-access workflows fail.

## Design requirements

- Maintain two cloud-only emergency identities with permanent Global Administrator assignments as explicit recovery exceptions.
- Do not associate them with an employee's daily identity, mailbox, routine license, PIM workflow or on-premises directory.
- Use independent phishing-resistant authentication paths and store recovery material in separately controlled locations.
- Place them in a dedicated emergency-access group used only for exclusions and monitoring.
- Exclude that group from policies that can block or restrict recovery sign-in; report-only policies do not require the exclusion but should still model it before promotion.
- Alert on every sign-in, authentication-method change, password reset, role change and group-membership change affecting the identities.
- Test each path independently at least quarterly and before a major access-control cutover.

## Controlled validation procedure

1. Open a clean browser session from an approved recovery workstation.
2. Authenticate with emergency identity A using its independent method.
3. Confirm access to Microsoft Entra admin center and the expected permanent Global Administrator assignment.
4. Perform no configuration change; record the sign-in and audit visibility.
5. End the session and repeat independently for emergency identity B.
6. Verify that monitoring generated the expected events without exposing recovery secrets.
7. Record separate Evidence IDs; one successful account does not verify the other.

## Recovery procedure

1. Declare the access-control incident and identify an incident owner.
2. Confirm routine administrative paths are unavailable or unsafe.
3. Retrieve one emergency credential through the approved dual-control process.
4. Sign in from the recovery workstation and inspect current Conditional Access, authentication and role state.
5. Make the smallest reversible change needed to restore routine administration.
6. Validate a normal administrative path before ending emergency use.
7. Restore the intended policy state, rotate exposed recovery material and investigate the triggering failure.
8. Record actor, time, reason, change, validation and rollback evidence.

## Conditional Access cutover gate

No Security Defaults replacement or Conditional Access enforcement is approved until both emergency identities are independently validated, replacement baseline policies are prepared, rollback is rehearsed and monitoring is available.

## Limitations

The lab demonstrates the runbook design and the decision gate. It does not claim a completed disaster-recovery exercise, multi-person vault custody or production monitoring coverage.
