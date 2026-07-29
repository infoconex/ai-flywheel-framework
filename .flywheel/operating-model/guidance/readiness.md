# Phase, Status, and Readiness Model

This document is normative. The Flywheel separates lifecycle position, current operability, and permission to begin application missions. These concepts MUST NOT be collapsed into one field.

## Phase

Allowed `state.phase` values are `onboarding`, `operating`, `upgrading`, and `suspended`. Detailed onboarding progression is represented by the active mission and goal, not by inventing additional phase or readiness values.

## Status

Allowed `state.status` values are:

- `ready`: no execution is active and the active goal may begin or continue.
- `active`: an execution is currently active.
- `blocked`: progress requires unresolved information, approval, access, dependency, or correction.
- `suspended`: work is intentionally paused.

## Readiness

Allowed `state.readiness` values are:

- `not-ready-for-missions`: application missions are prohibited because onboarding or certification is incomplete.
- `ready-for-missions`: the repository may accept application missions.
- `degraded`: the repository was previously ready, but a material operating defect or missing capability prevents reliable operation.

`state.application_missions_allowed` MUST be false unless readiness is `ready-for-missions`.

## Ready-for-missions gate

Every condition MUST be satisfied:

- Repository context is sufficient for future mission planning.
- Flywheel implementation context is approved.
- Governance and approval boundaries are explicit.
- Required capabilities are implemented or have an approved manual procedure.
- Operating artifacts validate against their schemas and invariants.
- Formal certification defined in `.flywheel/operating-model/guidance/certification.md` passes.
- A proving mission completes with traceable evidence.
- Known limitations are recorded and accepted.
- State, mission, goal, executions, records, approvals, and knowledge are internally consistent.

## Readiness transition procedure

A transition to `ready-for-missions` requires:

1. A readiness validation record mapping every gate to evidence.
2. Successful schema, reference, invariant, lifecycle, evidence, and approval validation.
3. A passing certification record covering cold start, first execution, resume, recovery, approval boundary, lifecycle completeness, evidence completeness, proving mission, and self-hosting.
4. Recorded human approval of the certification and known limitations.
5. Completion of the onboarding mission and its active goal.
6. An atomic state update setting `phase: operating`, `readiness: ready-for-missions`, `status: ready`, clearing active onboarding execution and lifecycle stage, and setting `application_missions_allowed: true`.

Readiness is not established merely by changing a field. A validator MUST reject a readiness transition without the required certification and approval evidence.

## Degradation

Set readiness to `degraded` when a material failure undermines reliable operation or invalidates a prior certification assumption. Existing application work may continue only when governance explicitly permits it and the risk is recorded. Restore readiness only after corrective validation, affected certification scenarios are rerun, and required approval is recorded.