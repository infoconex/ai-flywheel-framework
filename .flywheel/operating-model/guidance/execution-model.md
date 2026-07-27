# Execution Model

An execution is a single traceable attempt to advance an active goal.

## Before execution

The operator must:

1. Confirm the goal is active.
2. Restate the intended change or investigation.
3. Identify applicable acceptance criteria and validation.
4. Identify required approvals.
5. Create or initialize an execution record.

## During execution

Record material actions, observations, commands, outputs, changes, assumptions, and deviations. Do not wait until the end to reconstruct evidence from memory.

Every execution follows the Flywheel lifecycle:

1. Execute the planned action.
2. Observe actual results.
3. Evaluate results against expectations.
4. Classify meaningful outcomes.
5. Adapt the plan, implementation, or operating model when justified.
6. Validate acceptance criteria and safeguards.
7. Persist records, decisions, evidence, and validated knowledge.
8. Reuse applicable learning in subsequent work.

Stages may repeat, but none may be silently skipped. A stage with no applicable output must be recorded as not applicable with a reason.

## Execution outcomes

Allowed outcomes are:

- `succeeded`: the attempt achieved its intended result and validation passed.
- `partially-succeeded`: useful progress occurred but the goal remains incomplete.
- `failed`: the attempt did not achieve its intended result.
- `blocked`: progress requires unavailable information, approval, access, or dependency.
- `abandoned`: the attempt was intentionally stopped because another approach is preferable.

## Completion

An execution may succeed without completing the goal. A goal completes only when every acceptance criterion is satisfied, required evidence exists, validation passes, and required approval is recorded.

## Resume behavior

When resuming work, read prior executions in chronological order, preserve unresolved findings, and start a new execution unless the previous record explicitly indicates it was interrupted before any material action.