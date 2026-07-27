# Readiness Model

The Flywheel must prove operational readiness before application missions may begin.

## Readiness states

- `uninitialized`: required Flywheel artifacts are absent.
- `onboarding`: repository discovery and human configuration are incomplete.
- `designing-tools`: required Flywheel capabilities and implementation choices are being defined.
- `building-tools`: repository-specific Flywheel tooling is being implemented.
- `validating-tools`: tooling and operating behavior are being proven.
- `ready-for-missions`: the repository may accept application missions.
- `degraded`: previously ready, but a material framework defect or missing capability prevents reliable operation.

## Ready-for-missions gate

All conditions must be satisfied:

- Repository context is sufficient for future mission planning.
- Flywheel implementation context is approved.
- Governance and approval boundaries are explicit.
- Required capabilities are implemented or have an approved manual procedure.
- Mission, goal, execution, evidence, decision, and knowledge artifacts validate against their contracts.
- Startup and resume behavior have been tested from a context-free session.
- A proving mission completed with traceable evidence.
- Known limitations are recorded and accepted.
- State, mission, goal, records, and knowledge are internally consistent.

## Readiness validation

Readiness is not established by setting a field. A validation record must map every gate to evidence. Required human acceptance must be recorded before transition.

## Degradation

Set readiness to `degraded` when a material failure undermines reliable operation. Existing application work may continue only when governance explicitly permits it and the risk is recorded. Restore readiness only after corrective validation.