# Readiness Model

The Flywheel must prove operational readiness before application missions may begin.

## State dimensions

`.flywheel/state.yaml` uses separate dimensions:

- `phase`: where the Flywheel is in its establishment or operating lifecycle.
- `status`: whether work is ready, active, blocked, or suspended.
- `readiness`: whether application missions are permitted.

Allowed readiness values are:

- `not-ready-for-missions`
- `ready-for-missions`
- `degraded`

Onboarding, designing tools, building tools, and validating tools are phases or mission progress, not readiness values. During all of them, readiness remains `not-ready-for-missions`.

## Ready-for-missions gate

All conditions must be satisfied:

- Repository context is sufficient for future mission planning.
- Flywheel implementation context and material implementation decisions are approved.
- Governance and approval boundaries are explicit.
- Required capabilities are implemented or have an approved manual procedure that does not weaken conformance.
- Every manifest-required artifact exists.
- Manifest, state, goals, and executions validate against machine-readable schemas.
- Mission, goal, execution, filename-to-ID, state, approval, evidence, and record references are internally consistent.
- Every goal uses stable acceptance-criterion IDs and evidence mappings.
- Startup and resume behavior pass the configured context-free cold-start test.
- A proving mission completes with all lifecycle stages recorded and traceable evidence.
- Known limitations are recorded and accepted.
- No unresolved blocker prevents reliable operation.
- Human authority explicitly approves the readiness transition.

## Transition procedure

Readiness is not established by editing a field alone. Persist a readiness validation record that maps every gate to evidence and includes the human approval reference. Then update state atomically so:

- `readiness` becomes `ready-for-missions`.
- `application_missions_allowed` becomes `true`.
- `phase` becomes `operating`.
- `status` becomes `ready` unless an execution is active.

A partial transition is invalid and must be treated as an inconsistent state.

## Degradation

Set readiness to `degraded` when a material framework defect or missing capability undermines reliable operation. Application work may continue only when governance explicitly permits it and the risk is recorded. Restore readiness only after corrective validation and human approval.