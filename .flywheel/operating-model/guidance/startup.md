# Startup Protocol

This protocol is mandatory whenever a new operator or chat session begins work in the repository. All paths are repository-root-relative.

## Read order

1. Read `.flywheel/manifest.yaml`.
2. Resolve every manifest path relative to the repository root.
3. Read `.flywheel/state.yaml`.
4. Read every file listed in `required_files` in manifest order.
5. Read the active mission and active goal identified by state.
6. Read records for the active goal from the canonical locations defined in `.flywheel/operating-model/guidance/records.md`, oldest first.
7. When `active_execution` is not null, read that execution last and resume its recorded `lifecycle_stage`.
8. Inspect the target repository only after the operating contract is understood.

## Startup checks

Before changing any file, establish:

- The current phase, status, and readiness.
- The active mission, goal, execution, and lifecycle stage.
- Whether the requested work belongs to the active goal.
- Whether a prior execution is incomplete, blocked, or failed.
- Which approvals are present and still required.
- Which validation and evidence rules apply.
- Whether application work is permitted.
- Whether all required artifacts pass available schema and reference validation.

## Required opening report

Report:

- Current phase, status, and readiness.
- Active mission and goal.
- Active execution and lifecycle stage, or that a new execution must be created.
- Known blockers and required approvals.
- Applicable validation.
- The next authorized action.

## Execution start rule

Before the first material action in a session, create a new execution record unless state identifies an active resumable execution. Reading operating files and producing the opening report are not material actions. Repository inspection, asking an onboarding question, running a command, or changing a file are material actions.

Continue an existing execution only when:

- `state.active_execution` identifies it.
- Its status is `in-progress` or `interrupted`.
- Its mission and goal match state.
- Its last persisted lifecycle stage is known.

Otherwise create a new execution and update state before proceeding.

## Stop conditions

Stop and request human direction when:

- State and mission, goal, execution, or approval records disagree.
- The active mission or goal cannot be found.
- A required operating file is missing.
- Artifact validation fails in a way that makes authority or active work ambiguous.
- Requested work falls outside the active mission or goal.
- A material decision lacks required approval.
- Proceeding would weaken governance or validation merely to obtain success.

A missing implementation tool does not suspend this protocol. Operate the same process manually and record the capability limitation.