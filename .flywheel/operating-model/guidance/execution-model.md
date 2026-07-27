# Execution Model

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior. Explanatory text and examples are informative.

An execution is one traceable attempt to advance an active goal. Every goal-directed action belongs to exactly one execution.

## Goal-directed actions

Goal-directed actions include repository inspection, onboarding questions, commands, repository analysis, validation, evidence collection, approval requests, and file changes. Startup actions are limited to reading the operating contract, resolving active work, performing operating validation, and producing the opening report.

## Creation boundary

Immediately before the first goal-directed action, create a new execution unless `.flywheel/state.yaml` identifies an active resumable execution.

If no execution records exist for the active goal, this is the first execution. The absence of prior execution records is expected and MUST NOT be treated as missing data.

A new execution MUST:

1. Use the canonical location defined in `.flywheel/operating-model/guidance/records.md`.
2. Identify the active mission and goal.
3. Identify the intended outcome and applicable acceptance-criterion IDs.
4. Identify validation and required approvals.
5. Initialize all eight lifecycle stages as `pending`.
6. Set status to `in-progress`.
7. Atomically update state with `status: active`, the execution ID, and lifecycle stage `execute` before goal-directed work.

## During execution

Record goal-directed actions, observations, commands, outputs, changes, assumptions, evidence, and deviations as they occur. Do not reconstruct evidence from memory at the end.

Every execution MUST record all lifecycle stages:

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

Before beginning a stage, update the execution and `.flywheel/state.yaml` to that stage. After the stage, persist its status, summary, references, and timestamps. The state lifecycle stage MUST match the active execution.

## Outcomes

Allowed execution outcomes are `succeeded`, `partially-succeeded`, `failed`, `blocked`, `abandoned`, and `interrupted`.

An execution may succeed without completing the goal. Goal completion requires every acceptance criterion to be satisfied by referenced evidence, validation to pass, blockers to be disposed, and required approvals to exist.

## Resume behavior

Continue an execution only when state identifies it, its status is `in-progress` or `interrupted`, its mission and goal match state, and its persisted lifecycle stage is known. Otherwise begin a new execution. Read previous executions chronologically and preserve unresolved findings.

## Closure

When closing an execution:

1. Record its outcome and rationale.
2. Complete all lifecycle stage records, including justified `not-applicable` stages.
3. Persist referenced evidence, decisions, findings, approvals, and learning.
4. Clear `state.active_execution` and `state.lifecycle_stage`, unless the execution remains interrupted and resumable.
5. Set state status to `ready`, `blocked`, or `suspended` as supported by evidence.
6. Update goal and mission state only when their transition rules are satisfied.