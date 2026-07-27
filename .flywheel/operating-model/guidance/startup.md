# Startup Protocol

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior. Explanatory text and examples are informative.

This protocol is mandatory whenever a new operator or chat session begins work in the repository. All paths are repository-root-relative.

## Read order

1. Read `.flywheel/manifest.yaml`.
2. Resolve every manifest path relative to the repository root.
3. Read `.flywheel/state.yaml`.
4. Read every file listed in `required_files` in manifest order.
5. Read the active mission and active goal identified by state.
6. Read records for the active goal from the canonical locations defined in `.flywheel/operating-model/guidance/records.md`, oldest first.
7. When `active_execution` is not null, read that execution last and resume its recorded `lifecycle_stage`.
8. Do not inspect the target repository until startup is complete.

## Operating validation

Before producing the opening report, the operator MUST verify:

- Every manifest-required file exists.
- State, mission, goal, and any active execution satisfy their schemas when validation is available.
- Active references resolve uniquely and agree.
- The requested work belongs to the active mission and goal.
- Required approvals, blockers, evidence rules, and application-work permission are understood.

Operating validation concerns Flywheel artifacts only. Repository build, test, dependency, architecture, or source inspection belongs to goal execution.

During onboarding, before a repository-specific validator exists, Operating Validation SHALL be performed manually using the published validation contract. Manual validation performed according to that contract is authoritative and equivalent to automated validation for governance decisions until a repository-specific validator becomes available.

## Required opening report

The opening report SHALL use these headings in this exact order:

1. `Current Phase`
2. `Status`
3. `Readiness`
4. `Application Missions Permitted`
5. `Active Mission`
6. `Active Goal`
7. `Active Execution`
8. `Lifecycle Stage`
9. `Known Blockers`
10. `Required Approvals`
11. `Operating Validation`
12. `Repository Validation`
13. `Implementation Validation`
14. `Next Authorized Action`

The report MUST state whether an existing execution will be resumed or a new execution must be created.

At startup, before repository inspection or implementation work begins, the expected validation states are:

- `Operating Validation`: `passed`, or `failed` with a deterministic recovery action.
- `Repository Validation`: `pending` when execution has not started.
- `Implementation Validation`: `not-applicable` when no implementation work has occurred.

The operator MUST NOT report Repository Validation or Implementation Validation as passed without evidence gathered during an authorized execution.

## Startup completion checkpoint

Startup is complete only when:

- All required operating artifacts have been read.
- Operating validation has passed or a deterministic recovery action has been selected.
- The opening report has been produced.
- The execution decision has been made.

No goal-directed action may occur before this checkpoint.

## Execution boundary

A goal-directed action is any action that advances, investigates, validates, records, or changes the active goal. It includes repository inspection, onboarding questions, commands, analysis of repository content, validation, evidence collection, approval requests, and file changes.

Reading the operating contract and producing the opening report are startup actions, not goal-directed actions.

Immediately before the first goal-directed action, the operator MUST either:

- Resume the execution identified by state when it is resumable and consistent; or
- Create the first or next execution record, initialize all lifecycle stages, set it to `in-progress`, and atomically update state to `status: active`, the new `active_execution`, and `lifecycle_stage: execute`.

If no execution records exist for the active goal, that absence is expected for the first execution and is not a blocker.

## Repository inspection scope

When repository inspection is authorized by the active goal, it MUST consider applicable repository structure, documentation, configuration, build, tests, automation, tooling, dependencies, standards, constraints, and authoritative external references. The operator MUST record inspected areas, evidence sources, unknowns, and intentionally uninspected areas.

## Stop conditions

Stop and apply `.flywheel/operating-model/guidance/failure-handling.md` when:

- State and mission, goal, execution, or approval records disagree.
- The active mission or goal cannot be found.
- A required operating file is missing.
- Artifact validation makes authority or active work ambiguous.
- Requested work falls outside the active mission or goal.
- A material decision lacks required approval.
- Proceeding would weaken governance or validation merely to obtain success.

A missing implementation tool does not suspend this protocol. Operate the same process manually and record the capability limitation.