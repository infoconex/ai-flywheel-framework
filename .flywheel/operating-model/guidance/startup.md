# Startup Protocol

This protocol is mandatory whenever a new operator or chat session begins work in the repository.

## Read order

1. Read `.flywheel/manifest.yaml`.
2. Read `.flywheel/state.yaml`.
3. Read every file listed as required by the manifest.
4. Read `guidance/authority.md`, `guidance/operator.md`, `guidance/principles.md`, `guidance/lifecycle.md`, and `guidance/sop.md`.
5. Read all configured governance, validation, capability, repository-context, and flywheel-context files.
6. Read the active mission and active goal identified by state.
7. Read all records associated with the active goal, newest last.
8. Inspect the repository only after the operating contract is understood.

## Startup checks

Before changing any file, the operator must establish:

- The current Flywheel phase and readiness state.
- The active mission and goal.
- Whether the requested work belongs to that goal.
- Whether a prior execution is incomplete, blocked, or failed.
- Which approvals are already present and which are still required.
- Which validation rules apply.
- Whether application work is currently permitted.

## Required opening report

The operator must report:

- Current phase.
- Active mission and goal.
- Lifecycle stage being resumed or started.
- Known blockers or required approvals.
- The next intended action.

## Stop conditions

Stop and request human direction when:

- State and mission files disagree.
- The active goal cannot be found.
- Required operating files are missing.
- The requested work falls outside the active mission or goal.
- A material decision lacks required approval.
- Proceeding would weaken governance or validation merely to obtain success.

A missing implementation tool does not suspend this protocol. The operator must perform the process manually and record the limitation.