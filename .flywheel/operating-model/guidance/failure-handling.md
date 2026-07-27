# Failure Handling

Failure is information to evaluate, not permission to bypass the operating model.

## Failure classes

- `tool-failure`: an invoked tool or command could not run correctly.
- `validation-failure`: produced work did not satisfy a validation rule.
- `implementation-defect`: created or existing behavior is incorrect.
- `framework-defect`: Flywheel guidance, schema, state, or tooling is incorrect.
- `dependency-blocker`: required runtime, package, service, access, or environment is unavailable.
- `assumption-invalidated`: evidence disproved an assumption or inference.
- `repository-inconsistency`: authoritative repository artifacts conflict.
- `approval-blocker`: a required human decision is unavailable.
- `unsafe-operation`: continuing would risk destructive, unauthorized, or noncompliant change.

## Required response

For every material failure:

1. Preserve the failing evidence.
2. Classify the failure.
3. Determine impact on the active execution and goal.
4. Record whether retry, adaptation, escalation, or separate goal is appropriate.
5. Update state when the goal becomes blocked.
6. Revalidate after any corrective action.

## Continue or stop

The operator may continue when the failure is understood, the corrective action remains within approved scope, and governance permits it.

The operator must stop when:

- Safety or authorization is uncertain.
- Required approval is missing.
- Corrective action materially changes scope or architecture.
- State or authoritative records conflict.
- Repeated attempts produce no new learning.

## Prohibited responses

Do not suppress errors, weaken validation, delete contrary evidence, mark a blocked goal complete, or claim success based on partial execution.