# ADR-001: Hybrid Identity Model

- **Status:** Planned architecture direction; no hybrid deployment performed
- **Date:** 2026-09-23
- **Decision owner:** repository owner
- **Cloud change:** none

## Context

The portfolio scenario models an organization with an HR source, an on-premises Active Directory environment and Microsoft Entra ID. A synchronization product must not be selected before the authoritative source, target population, authentication requirements and recovery dependencies are defined.

The lab currently has cloud identities. It does not yet provide verified evidence of an operational on-premises directory, Entra Connect Sync, Cloud Sync or a hybrid authentication dependency in this clean-room environment.

## Decision drivers

- one governed identity lifecycle for on-premises and cloud access;
- minimum infrastructure and maintenance burden;
- resilience if on-premises authentication services are unavailable;
- least-privileged administration;
- scoped pilot and reversible deployment;
- support for observable provisioning and synchronization failures;
- no unnecessary Azure cost before the time-limited trial expires.

## Options

### Option A — Microsoft Entra Connect Sync with password hash synchronization

Suitable when broad synchronization capabilities or Connect-specific features are required. Password hash synchronization provides cloud authentication without a real-time dependency on on-premises authentication infrastructure. It requires a managed synchronization server and operational ownership.

### Option B — Microsoft Entra Cloud Sync

Uses lightweight provisioning agents and cloud-managed configuration. It can reduce local infrastructure and can be appropriate for selected topologies and scoped provisioning. Feature and topology requirements must be checked before selection.

### Option C — Pass-through authentication

Validates authentication against on-premises agents. It introduces a real-time dependency on on-premises connectivity and authentication availability, requiring resilient agents and monitoring.

### Option D — Federation

Provides externalized authentication through a federation service. It introduces greater infrastructure and operational complexity and requires a specific business or protocol requirement; it is not selected merely for architectural sophistication.

## Proposed decision

Do not deploy synchronization during the repository-foundation phase.

For the design baseline, prefer **password hash synchronization as the default authentication assumption** because it has the lowest deployment and maintenance burden among the compared hybrid authentication options and supports cloud authentication resilience.

Select **Connect Sync or Cloud Sync only after a documented capability and topology comparison**. The initial lab implementation should use the smallest reversible pilot population and explicit synchronization scoping.

The implemented cloud-only HR pipeline validates the upstream control pattern independently of the synchronization engine: authoritative attributes are checked, a deterministic plan is approved, birthright groups are calculated, live changes are piloted and a second run proves idempotency. This does not verify hybrid synchronization, but it reduces the number of untested lifecycle assumptions carried into a future hybrid pilot.

## Source-of-authority boundaries

| Attribute or control | Authoritative owner |
|---|---|
| Employment state, department, manager, start and end dates | HR source |
| AD-dependent application attributes | On-premises AD under approved mapping |
| Cloud authorization, PIM and Conditional Access | Microsoft Entra ID |
| Emergency identities | Cloud-only recovery process |
| Manual exceptions | Governed request with owner, expiry and reconciliation |

Self-service users must not be able to modify attributes that drive security-sensitive dynamic membership.

## Required discovery before approval

1. Verify whether an on-premises AD DS environment exists for this clean-room project.
2. Define the authoritative HR and directory sources.
3. Define the pilot organizational unit or group and exclusion rules.
4. Identify unsupported attributes, object types and topology requirements.
5. Define accidental-deletion protection, monitoring and rollback.
6. Verify licensing, host requirements and any Azure cost.
7. Preserve independent emergency access that does not depend on synchronization.

## Validation plan

- preview the scoped objects before export;
- provision a small set of synthetic pilot identities;
- validate create, update, disable and scope-exclusion behavior;
- validate authentication during simulated loss of synchronization connectivity;
- inspect provisioning/synchronization health and error handling;
- record a sanitized Evidence ID for each observed result.

## Rollback

- stop the approved pilot synchronization path;
- restore the saved configuration and scoping state;
- confirm that cloud-only emergency access remains usable;
- reconcile pilot objects and document source-of-authority behavior before deletion or conversion;
- do not delete identities as an unreviewed rollback shortcut.

## Production limitations

This ADR documents an architecture direction, not a completed hybrid deployment. A small lab cannot prove global availability, forest-scale performance, complex attribute precedence, regulatory suitability or operational support maturity.
