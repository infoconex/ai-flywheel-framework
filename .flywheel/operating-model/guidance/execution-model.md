# Execution Model

An execution is one traceable attempt to advance an active goal. A session may contain multiple executions, but every material action belongs to exactly one execution.

## Creation boundary

Before the first material action, create a new execution unless `.flywheel/state.yaml` identifies an active resumable execution. Reading the operating contract and producing the opening report are not material actions. Repository inspection, asking an onboarding question, running a command, changing a file, or requesting a material approval are material actions.

A new execution must:

1. Use the canonical location defined in `.flywheel/operating-model/guidance/records.md`.
2. Identify the active mission and goal.
3. Identify the intended outcome and applicable acceptance-criterion IDs.
4. Identify validation and required approvals.
5. Initialize all eight lifecycle stages as `pending`.
6. Set status to `in-progress`.
7. Update state with the execution ID and lifecycle stage `execute` before material work.

## During execution

Record material actions, observations, commands, outputs, changes, assumptions, and deviations as they occur. Do not reconstruct evidence from memory at the end.

Every execution records all lifecycle stages:

1. Execute
2. Observe
3. Evaluate
4. Classify
5. Adapt
6. Validate
7. Persist
8. Reuse

A stage may repeat. No stage may be omitted. When a stage has no action or output, record status `not-applicable` and a concrete reason.

## Stage transitions

Before beginning a stage, update the execution and `.flywheel/state.yaml` to that stage. After the stage, persist its status, summary, references, and timestamps. The state lifecycle stage must match the active execution.

## Outcomes

Allowed execution outcomes are:

- `succeeded`
- `partially-succeeded`
- `failed`
- `blocked`
- `abandoned`
- `interrupted`

An execution may succeed without completing the goal. Goal completion requires every acceptance criterion to be satisfied by referenced evidence, validation to pass, blockers to be disposed, and required approvals to exist.

## Resume behavior

Continue an execution only when state identifies it and its status is `in-progress` or `interrupted`. Otherwise begin a new execution. Read previous executions chronologically and preserve unresolved findings.

## Closure

When closing an execution:

1. Record its outcome and rationale.
2. Complete all lifecycle stage records, including justified `not-applicable` stages.
3. Persist referenced evidence, decisions, findings, and approvals.
4. Clear `state.active_execution` and `state.lifecycle_stage`, unless the execution remains interrupted and resumable.
5. Update goal and mission state only when their transition rules are satisfied.