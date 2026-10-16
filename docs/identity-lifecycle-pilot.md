# Identity Lifecycle Pilot

## Status

**Planned** — the HR source and automation are prepared locally. No user attribute update is implied by this document.

## Flow

`HR-style CSV -> validation -> local alias mapping -> Microsoft Graph -> Entra user attributes -> dynamic group rules -> access assignment`

The public HR dataset contains synthetic aliases and business attributes only. By default the script requests each live UPN interactively and keeps it only in process memory. For repeatable operator runs, the repository contains a placeholder mapping template, but any populated mapping must be stored outside the repository and passed through `-UserMapPath`.

## Pilot

Two existing sample identities represent an employee in Finance and an identity-support employee in IT. The script defaults to dry-run and requires the explicit `-Apply` switch to change Microsoft Entra ID.

## Permission model

Dry-run requests delegated `User.Read.All`. Apply mode requests delegated `User.ReadUpdate.All`. The script does not request directory-wide write access, password permissions, role-management permissions or application credentials. Microsoft documents `User.ReadUpdate.All` as the least-privileged delegated permission for updating other work or school user profiles.

Production HR integration would normally use a governed provisioning service or workload identity rather than an administrator's interactive session. That future identity would receive only the permissions required for the approved lifecycle properties and would not store a client secret in the repository.

## Interview relevance

The pilot demonstrates that large workforces are managed through authoritative attributes and policy, not by manually editing each identity. Scale is represented through repeatable input validation, deterministic mappings, dry-run behavior and later synthetic testing—not by creating a thousand unnecessary live accounts.

## Validation

After an approved apply operation:

1. Re-run the script without `-Apply`; every record must return `NO CHANGE`.
2. Confirm the four permitted attributes in Microsoft Entra admin center.
3. Confirm that no role, license or authentication method changed.

## Rollback

Capture the original permitted attributes before apply. Rollback uses the same validated mechanism with the captured values; no user deletion is part of this pilot.
