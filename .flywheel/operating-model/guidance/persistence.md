# Persistence and Reuse

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

Persistence makes execution state, records, confirmed context, and selected learning durable across sessions.

## Persist activation

Persist MUST NOT begin until Validate is `completed` or justified as `not-applicable`, no required validation remains pending, every failed required validation has a finding, recovery action, and authorized disposition, and adaptation validation statuses agree with validation results.

Before Persist becomes `in-progress`, the operator MUST construct and validate one structured persistence plan using `persistence-plan.schema.yaml`. The plan MUST be referenced by the Persist stage.

## Complete target-set derivation

The persistence target set MUST be derived from the current execution and include every durable artifact that is new or changed because of the execution:

- Evidence, decisions, findings, and approvals referenced by the execution.
- The active execution record.
- Goal, mission, state, repository context, or Flywheel context when their durable values change.
- Knowledge only when promotion requirements are satisfied.
- The persistence plan itself.

A referenced artifact MUST NOT be omitted. An unchanged artifact MUST NOT be added merely to enlarge the transaction. Every target MUST have one canonical path, one operation, one mutability rule, one precondition, one proposed-content digest, and one recovery action.

## Canonical mutation semantics

- Evidence, decisions, findings, approvals, and persistence plans are create-only records. Existing records MUST NOT be overwritten.
- Execution, goal, mission, state, and context artifacts use compare-and-swap updates against retained blob SHAs.
- Knowledge is create-only for a new identity. Revisions use a new identity and `supersedes` linkage; existing knowledge MUST NOT be silently overwritten.
- Create operations require confirmed path absence immediately before creation.
- Update operations require retained complete content and retained blob SHA.
- Identifier or path collision requires selecting the next deterministic identity when the identity contract permits it; otherwise the transaction fails before writing.

## Deterministic write order

Targets MUST be topologically ordered by their declared dependencies and then by this type precedence:

1. Evidence.
2. Decisions.
3. Findings.
4. Approvals.
5. Knowledge.
6. Context.
7. Goal.
8. Mission.
9. Execution.
10. State.
11. Persistence plan finalization.

Within one type, order by target ID ascending. A target MUST NOT be written before every dependency target is durable and verified.

State is the final operational pointer and MUST be written after every artifact it references, including execution. The durable execution/state pair rules in `execution-model.md` remain mandatory within this larger transaction.

## Pre-write validation

Before the first write, the operator MUST:

1. Resolve one stable operator identity and one whole-second UTC transaction instant.
2. Construct the complete proposed durable set in memory.
3. Validate every proposed artifact against its schema and semantic rules.
4. Validate all paths, identities, target dependencies, references, timestamps, and lifecycle invariants.
5. Retain the complete content and blob SHA of every update target.
6. Confirm path absence for every create target.
7. Re-read every target precondition immediately before the first write.
8. Reject the transaction without writing when any precondition is stale or any target is missing from the plan.

## Application and verification

Apply targets in the exact validated write order. After each write, re-read the artifact and verify its content digest equals the proposed digest before proceeding.

After all writes, re-read the entire target set and verify:

- Every create target exists exactly once at the planned path.
- Every update target equals the validated proposed content.
- Every reference resolves.
- State and execution agree on mission, goal, execution, status, and sole active stage.
- No unplanned artifact was changed.
- The persistence plan records `status: applied` and final verification `result: passed`.

Persist MUST NOT be reported durable or completed until whole-set verification passes.

## Partial-persistence recovery

When any write or verification fails:

1. Stop forward writes immediately.
2. Preserve the failing result and current artifact revisions.
3. Roll back successfully updated mutable targets in reverse write order using compare-and-swap and exact retained content.
4. Delete successfully created records in reverse write order only when they are unreferenced by any durable artifact and the create operation established ownership of the current path revision.
5. When safe deletion is not possible, create a compensating finding that identifies the orphaned record and prohibits its use.
6. Re-read the complete affected set and verify restoration.
7. Persist a finding containing the plan ID, target IDs, preconditions, successful writes, failed write, rollback or compensation results, current revisions, and required recovery.
8. If restoration succeeds, mark the plan `rolled-back` and leave the lifecycle transition unapplied.
9. If restoration cannot be proven, mark the plan `blocked`, add a blocker to state through an authorized recovery transition, and require human reconciliation.

A rollback MUST NOT overwrite concurrent changes. Failure to restore one target blocks further lifecycle work.

## Required semantic rules

- `PERSIST-PLAN-001`: Persist activation requires a schema-valid complete persistence plan.
- `PERSIST-TARGET-001`: Every new or changed durable artifact is represented exactly once in the target set.
- `PERSIST-LOCATION-001`: Every target uses its canonical path and identity rules.
- `PERSIST-MUTABILITY-001`: Create-only history is never overwritten; mutable artifacts use compare-and-swap.
- `PERSIST-ORDER-001`: Targets follow dependency order and canonical type precedence; state is the final operational pointer.
- `PERSIST-PRECHECK-001`: Every create absence and update SHA is rechecked before the first write.
- `PERSIST-VERIFY-001`: Each write and the final whole set are re-read and exactly verified.
- `PERSIST-ROLLBACK-001`: Partial persistence triggers reverse-order exact rollback or explicit compensation.
- `PERSIST-PARTIAL-001`: Unrecoverable partial persistence creates a durable finding, blocks continuation, and requires human reconciliation.
- `PERSIST-HISTORY-001`: Prior execution, validation, evidence, decision, finding, approval, and knowledge history is preserved.
- `PERSIST-REUSE-001`: Persist MUST NOT claim Reuse completion or promote unqualified knowledge.

## Persist completion

Persist may complete only when the persistence plan is applied, final whole-set verification passes, all required references resolve, the Persist stage has summary and timestamps, and no persistence blocker remains.

## Records versus knowledge

Records preserve what happened during a specific mission, goal, and execution. Knowledge contains validated, reusable information expected to help future work.

Do not promote an observation directly to knowledge. Promotion requires supporting evidence, applicability and limitation evaluation, validation or repeated confirmation, a clear reuse instruction, and provenance to originating records.

Knowledge may be `candidate`, `validated`, `deprecated`, or `superseded`. New evidence MUST NOT silently overwrite prior knowledge. Preserve history and link replacements.

## Reuse

At startup and goal planning, search validated knowledge for applicable guidance. Record whether it was reused, rejected as inapplicable, or exposed a need for revision.
