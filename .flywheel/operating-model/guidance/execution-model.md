# Execution Model

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

An execution is one traceable attempt to advance an active goal. Every goal-directed action belongs to exactly one execution.

## Creation boundary

Immediately before the first goal-directed action, create a new execution unless `.flywheel/state.yaml` identifies an active resumable execution.

If no execution records exist for the active goal, this is the first execution. The absence of prior execution records is expected.

## Deterministic execution identity

Execution identifiers MUST use `EX-YYYYMMDDTHHMMSSZ-NNN`, where the timestamp is the UTC creation instant and `NNN` is a three-digit collision counter beginning at `001`. The operator MUST select the lowest unused counter for that timestamp beneath the active goal's canonical execution directory. The filename MUST equal `<execution-id>.yaml`.

## Initial activation snapshot

The execution and state MUST become durable as one compare-and-swap transition. The execution artifact created before the state update MUST already contain the activation snapshot that state will reference:

- `status: in-progress`
- `started_at`: the execution creation UTC timestamp
- `completed_at: null`
- `intended_outcome`: the active goal objective
- `acceptance_criteria`: the active goal acceptance-criterion IDs in goal order
- `lifecycle.execute.status: in-progress`
- `lifecycle.execute.started_at`: exactly equal to execution `started_at`
- The other seven lifecycle stages: `pending` with null timestamps, summary, and reason
- `actions`, `observations`, `classifications`, `adaptations`, `blockers`, `approval_refs`, `evidence_refs`, `decision_refs`, `finding_refs`, and `validation_results`: empty arrays
- `outcome: null`
- Completion disposition and rationale: null

Required approvals are represented by the active goal's `approvals_required` values. Approval records are added to `approval_refs` only after they exist; therefore an initially empty `approval_refs` array is valid.

The corresponding state update MUST set:

- `status: active`
- `active_execution`: the new execution ID
- `lifecycle_stage: execute`
- `last_durable_update.at`: exactly equal to execution `started_at`
- `last_durable_update.by`: the operator identity used in the execution-creation evidence
- `last_durable_update.reason`: `Activated execution <execution-id> for goal <goal-id>.`

All other state fields remain unchanged.

## Durable creation sequence

1. Read and retain the current state blob SHA.
2. Select the deterministic execution ID.
3. Create the fully valid activation-snapshot execution using create-only semantics.
4. Re-read state and verify its SHA is unchanged.
5. Update state using compare-and-swap against the retained SHA.
6. If state changed, do not overwrite it. Persist a startup-failure record using `startup-failure.schema.yaml`, identifying the created execution as orphaned, and stop.

A finding record is not used for a creation collision because no execution became active.

## During execution

Record goal-directed actions, observations, commands, outputs, changes, assumptions, evidence, and deviations as they occur. Do not reconstruct evidence from memory.

Every execution records all eight lifecycle stages: execute, observe, evaluate, classify, adapt, validate, persist, and reuse.

Before beginning a later stage, update the execution and state together so exactly that stage is `in-progress`; earlier stages are `completed` or `not-applicable`, and later stages are `pending`. State `lifecycle_stage` MUST equal the execution's sole `in-progress` stage.

## Outcomes and resumability

Allowed execution statuses are `in-progress`, `blocked`, `succeeded`, `partially-succeeded`, `failed`, `abandoned`, and `interrupted`.

`in-progress`, `blocked`, and `interrupted` are resumable and mutable. For `blocked` or `interrupted`, `completed_at`, `outcome`, and completion disposition remain null. `blocked` requires at least one blocker. `interrupted` requires a nonempty interruption reason in `outcome` while remaining resumable.

`succeeded`, `partially-succeeded`, `failed`, and `abandoned` are terminal and immutable. They require all lifecycle stages to be completed or justified as not applicable, plus `completed_at`, outcome, disposition, and rationale.

Continue an execution only when state identifies it, its status is resumable, its mission and goal match state, and exactly one lifecycle stage is in progress.

## Closure

When closing a terminal execution:

1. Record its outcome and rationale.
2. Complete all lifecycle stage records, including justified `not-applicable` stages.
3. Persist referenced evidence, decisions, findings, approvals, and learning.
4. Clear `state.active_execution` and `state.lifecycle_stage`.
5. Set state status to `ready`, `blocked`, or `suspended` as supported by evidence.
6. Update `last_durable_update` for the same durable transition.
7. Update goal and mission state only when their transition rules are satisfied.
