# Phase, Status, and Readiness Model

The Flywheel separates lifecycle position, current operability, and permission to begin application missions. These concepts must not be collapsed into one field.

## Phase

Allowed `state.phase` values are:

- `onboarding`: repository context and Flywheel operating capability are being established.
- `operating`: the Flywheel is executing approved missions.
- `upgrading`: the operating model or implementation is undergoing a controlled material upgrade.
- `suspended`: operation has been intentionally paused.

Detailed onboarding progression is represented by the active mission and goal, not by inventing additional phase or readiness values.

## Status

Allowed `state.status` values are:

- `ready`: no execution is active and the active goal may begin or continue.
- `active`: an execution is currently active.
- `blocked`: progress requires unresolved information, approval, access, dependency, or correction.
- `suspended`: work is intentionally paused.

## Readiness

Allowed `state.readiness` values are:

- `not-ready-for-missions`: application missions are prohibited because onboarding or operational proof is incomplete.
- `ready-for-missions`: the repository may accept application missions.
- `degraded`: the repository was previously ready, but a material operating defect or missing capability prevents reliable operation.

`state.application_missions_allowed` must be false unless readiness is `ready-for-missions`.

## Ready-for-missions gate

All conditions must be satisfied:

- Repository context is sufficient for future mission planning.
- Flywheel implementation context is approved.
- Governance and approval boundaries are explicit.
- Required capabilities are implemented or have an approved manual procedure.
- Mission, goal, execution, evidence, decision, approval, finding, and knowledge artifacts validate against their contracts.
- Startup and resume behavior have been tested from a context-free session.
- A proving mission completed with traceable evidence.
- Known limitations are recorded and accepted.
- State, mission, goal, records, and knowledge are internally consistent.

## Readiness transition procedure

A transition to `ready-for-missions` requires:

1. A readiness validation record mapping every gate to evidence.
2. Successful artifact and reference validation.
3. Successful context-free cold-start test.
4. Successful proving mission.
5. Recorded human approval.
6. Completion of the onboarding mission and its active goal.
7. An atomic state update setting `phase: operating`, `readiness: ready-for-missions`, `status: ready`, clearing active onboarding execution and lifecycle stage, and setting `application_missions_allowed: true`.

Readiness is not established merely by changing a field.

## Degradation

Set readiness to `degraded` when a material failure undermines reliable operation. Existing application work may continue only when governance explicitly permits it and the risk is recorded. Restore readiness only after corrective validation and required approval.
