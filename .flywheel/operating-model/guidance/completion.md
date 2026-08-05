# Completion

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

Completion closes the active Reuse stage, execution, and goal after every required reuse assessment is completed and durable.

## Governed completion operation

A repository implementation MAY provide a governed `complete-execution` operation instead of requiring a second standalone persistence-plan artifact for Reuse closure when all of the following are true:

- Persist is already terminal and verified.
- Every required reuse assessment is durable, schema-valid, completed, and immutable.
- Every adaptation reuse status agrees with its completed assessments.
- The operation validates the complete proposed repository state before writing.
- Existing mutable artifacts use retained-content compare-and-swap preconditions.
- The execution, goal, optional next goal, optional mission, and state are committed as one atomic validated mutation.
- State is the final operational pointer and no partial completion may be reported.
- Any validation or compare-and-swap failure leaves every governed artifact unchanged.

When these requirements are met, the atomic completion mutation is the authoritative durability boundary for Reuse completion. A redundant second persistence-plan artifact is not required.

An implementation that cannot satisfy this atomic validated mutation contract MUST use the dedicated Reuse persistence plan described in `reuse.md` and `persistence.md`.

## Execution and goal completion

The completion operation MUST:

- complete Reuse with a summary, references, and timestamps;
- mark the execution terminal with its outcome and completion disposition;
- mark the active goal completed;
- clear `active_goal`, `active_execution`, and `lifecycle_stage` in state;
- ready at most one eligible dependent goal;
- preserve blockers and approval boundaries accurately;
- reject completion when required validation, evidence, assessment, approval, or reference integrity is incomplete.

## Mission completion

Completing the final goal does not by itself prove mission completion.

When no next goal is eligible, the completion operation MUST either:

- complete the mission when every mission success criterion is supported, no unresolved mission blocker remains, and no required mission-level approval is pending; or
- retain the mission as active and record the concrete reason that mission completion remains governed or approval-bound.

An approval required only for a later external action, such as tagging, publishing, releasing, uploading artifacts, or enabling hosted automation, MUST NOT keep a preparation mission active when that external action is explicitly outside the mission objective. Such work should be represented by a later goal, mission, or approval-bound operation.

## Required semantic rules

- `COMPLETE-ATOMIC-001`: Governed completion is atomic across every changed mutable artifact and state.
- `COMPLETE-CAS-001`: Existing mutable artifacts use retained-content compare-and-swap preconditions.
- `COMPLETE-REUSE-001`: Reuse may close only after every required assessment is completed and consistent with adaptation reuse status.
- `COMPLETE-GOAL-001`: Execution and goal completion are committed together.
- `COMPLETE-MISSION-001`: A final goal triggers explicit mission-completion evaluation rather than implicit retention or implicit closure.
- `COMPLETE-STATE-001`: State is written last and contains no active execution or lifecycle stage after successful completion.
- `COMPLETE-ROLLBACK-001`: Any failed completion attempt leaves the governed repository set unchanged.
