# Execution Model

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

An execution is one traceable attempt to advance an active goal. Every goal-directed action belongs to exactly one execution.

## Creation boundary

Immediately before the first goal-directed action, create a new execution unless `.flywheel/state.yaml` identifies an active resumable execution.

If no execution records exist for the active goal, this is the first execution. The absence of prior execution records is expected.

## Operator identity

Before selecting an execution identifier, the operator MUST resolve one stable identity string for the current session. Use the authenticated repository actor when tooling exposes it. Otherwise use `chatgpt-session`. The same identity MUST be used in state metadata and any startup-failure record created by this transition.

## Timestamp and identity

The creation instant MUST be captured once in UTC at whole-second precision using `YYYY-MM-DDTHH:MM:SSZ`. Fractional seconds are prohibited for execution activation. The compact form is produced by removing `-` and `:` from that exact timestamp.

Execution identifiers MUST use `EX-YYYYMMDDTHHMMSSZ-NNN`, where `NNN` begins at `001`. The operator MUST inspect the canonical execution directory and choose the lowest unused counter for the captured second. The filename MUST equal `<execution-id>.yaml`.

If create-only persistence reports that the selected path already exists, re-list the directory, select the next lowest unused counter for the same captured second, and retry. Repeat until creation succeeds or the counter would exceed `999`. Counter exhaustion is an Operating Validation failure and MUST be persisted as a startup-failure record.

## Initial activation snapshot

The execution artifact created before the state update MUST already contain the activation snapshot state will reference:

- `status: in-progress`
- `started_at`: the captured whole-second UTC creation instant
- `completed_at: null`
- `intended_outcome`: the active goal objective exactly
- `acceptance_criteria`: the active goal acceptance-criterion IDs in goal order
- `lifecycle.execute.status: in-progress`
- `lifecycle.execute.started_at`: exactly equal to execution `started_at`
- The other seven lifecycle stages: `pending` with null timestamps, summary, and reason
- `actions`, `observations`, `classifications`, `adaptations`, `blockers`, `approval_refs`, `evidence_refs`, `decision_refs`, `finding_refs`, and `validation_results`: empty arrays
- `outcome: null`
- Completion disposition and rationale: null

Required approvals are represented by the active goal's `approvals_required` values. Approval records are added to `approval_refs` only after they exist.

The corresponding state update MUST set:

- `status: active`
- `active_execution`: the new execution ID
- `lifecycle_stage: execute`
- `last_durable_update.at`: exactly equal to execution `started_at`
- `last_durable_update.by`: the resolved operator identity
- `last_durable_update.reason`: `Activated execution <execution-id> for goal <goal-id>.`

All other state fields remain unchanged.

## Durable creation sequence

1. Resolve the stable operator identity.
2. Capture one whole-second UTC creation instant.
3. Read and retain the current state blob SHA.
4. Select the deterministic execution ID.
5. Create the fully valid activation-snapshot execution using create-only semantics, applying the same-second counter retry rule on path collision.
6. Re-read state and verify its SHA is unchanged.
7. Update state using compare-and-swap against the retained SHA.
8. If state changed, do not overwrite it. Persist a startup-failure record using `startup-failure.schema.yaml`, identifying the created execution as orphaned, and stop.

A finding record is not used for a creation collision because no execution became active.

## Template use

`.flywheel/operating-model/templates/execution.yaml` is a schema-valid example, not an execution record. Before persistence, replace its example identity, timestamps, mission, goal, objective, and acceptance criteria using the rules above. The resulting artifact MUST validate before create-only persistence.

## During execution

Record goal-directed actions, observations, commands, outputs, changes, assumptions, evidence, and deviations as they occur. Do not reconstruct evidence from memory.

Every execution records all eight lifecycle stages: execute, observe, evaluate, classify, adapt, validate, persist, and reuse.

Before beginning a later stage, update the execution and state together so exactly that stage is `in-progress`; earlier stages are `completed` or `not-applicable`, and later stages are `pending`. State `lifecycle_stage` MUST equal the execution's sole `in-progress` stage.

## Outcomes and resumability

Allowed execution statuses are `in-progress`, `blocked`, `succeeded`, `partially-succeeded`, `failed`, `abandoned`, and `interrupted`.

`in-progress`, `blocked`, and `interrupted` are resumable and mutable. `in-progress` requires `outcome: null`. `blocked` requires at least one blocker and may use `outcome` to state the blocking condition. `interrupted` requires a nonempty interruption reason in `outcome`. All resumable statuses require `completed_at` and completion disposition and rationale to remain null.

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