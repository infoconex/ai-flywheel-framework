# Record Locations and Naming

All paths are repository-root-relative.

## Canonical goal record root

Records for a goal are stored under:

`.flywheel/operations/records/<mission-id>/<goal-id>/`

Required subdirectories are:

- `executions/`
- `evidence/`
- `decisions/`
- `findings/`
- `approvals/`

## Naming

Use UTC timestamps and stable identifiers:

- Execution: `executions/<execution-id>.yaml`
- Evidence: `evidence/<evidence-id>.yaml`
- Decision: `decisions/<decision-id>.yaml`
- Finding: `findings/<finding-id>.yaml`
- Approval: `approvals/<approval-id>.yaml`

Recommended identifiers use `YYYYMMDDTHHMMSSZ-<short-name>`.

## Ordering and discovery

Read records by their `created_at` value, oldest first. File names are a secondary ordering signal only. Records must identify `mission_id` and `goal_id`. Execution records must also identify their lifecycle state and referenced evidence, decisions, findings, and approvals.

## Active execution

`.flywheel/state.yaml` is the authoritative pointer to an active execution. It must match an existing execution record under the active mission and goal. A missing or mismatched record is a stop condition.

## Durability

Do not rely on chat transcripts as records. Persist material observations, commands, outputs, decisions, approvals, failures, and lifecycle results before ending a session.