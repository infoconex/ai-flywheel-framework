# Artifact Contracts

These contracts define the semantic expectations for Flywheel artifacts. Formal schemas are authoritative for single-artifact shape and allowed values. This document is authoritative for cross-artifact, repository-layout, transition, identity, and persistence invariants that JSON Schema cannot express.

A narrative requirement and its formal schema MUST agree. A discrepancy is an operating-model defect: startup validation MUST fail, no execution may be created, and no target-repository inspection may begin until the discrepancy is reconciled.

## Validator semantics

Schema validation SHALL use JSON Schema Draft 2020-12 semantics after parsing YAML 1.2. The validator MUST enforce `format`, including `date-time`. Timestamps MUST be RFC 3339 UTC values ending in `Z`. Execution-activation and startup-failure timestamps MUST use whole-second precision with no fractional component.

Validation has two required layers:

1. Schema validation checks one artifact's required shape, allowed fields, values, and local conditionals.
2. Invariant validation checks paths, uniqueness, references, ordering, transitions, cross-artifact agreement, and repository state.

Passing schema validation alone is never sufficient for Operating Validation.

## Canonical identity and paths

Identifiers are case-sensitive. Symlinks are not followed. Only regular files beneath manifest-declared canonical locations participate in identity resolution.

Canonical paths are:

- Mission: `.flywheel/operations/missions/<mission-id>/mission.yaml`
- Goal: `.flywheel/operations/missions/<mission-id>/goals/<goal-id>.yaml`
- Execution: `.flywheel/operations/records/<mission-id>/<goal-id>/executions/<execution-id>.yaml`
- Evidence: `.flywheel/operations/records/<mission-id>/<goal-id>/evidence/<record-id>.yaml`
- Decision: `.flywheel/operations/records/<mission-id>/<goal-id>/decisions/<record-id>.yaml`
- Finding: `.flywheel/operations/records/<mission-id>/<goal-id>/findings/<record-id>.yaml`
- Approval: `.flywheel/operations/records/<mission-id>/<goal-id>/approvals/<record-id>.yaml`
- Knowledge: `.flywheel/operations/knowledge/<knowledge-id>.yaml`
- Startup failure: `.flywheel/operations/records/startup-failures/<startup-failure-id>.yaml`

A path segment derived from an identifier MUST equal the identifier exactly. Duplicate identifiers, duplicate canonical paths, case-only collisions, or an artifact found outside its canonical location fail Operating Validation.

Record directories are lazy. Their absence is valid until the first record of that kind is persisted.

## Manifest

The manifest identifies schema version, framework name and version, fixed canonical locations, fixed startup entrypoint, required operating files, onboarding state, implementation state, and compatibility expectations. Every listed file must exist exactly once as a regular file.

## State

State identifies readiness, phase, status, active mission, active goal, active execution when present, lifecycle stage, application-work permission, blockers, and the last durable update.

Required combinations are:

- An active goal requires an active mission.
- An active execution requires an active goal and active mission.
- A lifecycle stage requires an active execution.
- `status: active` requires an active execution.
- No active execution requires a null lifecycle stage.
- Non-ready readiness requires `application_missions_allowed: false`.
- A blocked state requires at least one blocker.

Every active reference must resolve to exactly one canonical artifact, and all reciprocal identifiers must agree.

## Mission and goal

A mission contains its objective, status, success criteria, and ordered goal references. Goal list order is authoritative unless dependencies block progress.

A goal contains its mission identifier, objective, status, acceptance criteria, and required-evidence mappings. Every acceptance criterion must have exactly one evidence mapping.

## Execution

An execution contains identifiers, status, intended outcome, acceptance-criterion snapshot, timestamps, all eight lifecycle stages, actions, observations, classifications, adaptations, validation results, references, blockers, outcome, and completion disposition.

The acceptance-criterion list must exactly equal the active goal's criterion identifiers in goal order at execution creation and is immutable for that execution.

`in-progress`, `blocked`, and `interrupted` executions are resumable and mutable. Each MUST have exactly one `in-progress` lifecycle stage. Stages before it must be `completed` or `not-applicable`; stages after it must be `pending`. State lifecycle stage MUST equal that sole in-progress stage.

`succeeded`, `partially-succeeded`, `failed`, and `abandoned` executions are terminal and immutable. They MUST have no pending or in-progress lifecycle stages and require completion timestamp, outcome, disposition, and rationale.

`in-progress` requires `outcome: null`. `blocked` requires at least one blocker. `interrupted` requires a nonempty interruption reason in `outcome`.

## Deterministic identities

Execution IDs use `EX-YYYYMMDDTHHMMSSZ-NNN`. Startup-failure IDs use `SF-YYYYMMDDTHHMMSSZ-NNN`. For each type, capture one whole-second UTC timestamp and select the lowest unused three-digit counter beginning at `001` in the canonical directory. The filename equals `<id>.yaml`.

If create-only persistence collides, re-list the directory and retry with the next lowest unused counter for the same timestamp. Counter exhaustion at `999` is a blocking Operating Validation failure.

## Operator identity

Use the authenticated repository actor when tooling exposes it. Otherwise use the literal identity `chatgpt-session`. The same resolved identity is used for the complete transition and any associated failure record.

## Durable update protocol

Repository files cannot provide a true multi-file transaction. Therefore "atomic" means:

1. Resolve operator identity and capture the required whole-second timestamp.
2. Read and retain the current state hash or blob SHA.
3. Create the new execution or record at its canonical path using create-only semantics and the deterministic collision rule.
4. Re-read state and verify its hash is unchanged.
5. Update state using compare-and-swap against the retained hash.
6. If state changed, do not overwrite it. Persist a startup-failure record identifying any created execution as orphaned and stop.

Two operators must never overwrite each other's state.

## Startup-failure persistence

A startup-failure ID uses the deterministic identity rule above. Its canonical filename is `<startup-failure-id>.yaml`. Recording a startup defect is a startup action, not goal-directed work. The record contains the observed revision, branch, operator, timestamp, failed rules, artifact paths, evidence, recovery action, and orphaned execution identifier when applicable.

State may change to blocked only when its existing hash still matches and the failure directly prevents active work from starting.

## Revision consistency

At startup, resolve and report the immutable commit SHA when tooling makes it available. All artifacts used for one validation result must come from that revision. State transitions and certification records must include that revision in their evidence.

## Validation invariants

- Identifiers are stable and unique within their artifact type.
- References resolve and agree in both directions where both artifacts carry the relationship.
- Manifest locations and entrypoint equal canonical paths.
- Every manifest-required file exists.
- Active and resumable executions have exactly one in-progress stage.
- Terminal executions have no pending or in-progress stages.
- Goal completion requires evidence mapped to every acceptance criterion.
- Approved status requires approval evidence.
- Application missions require readiness `ready-for-missions`.
- Historical records are immutable except through explicit supersession metadata.
- Validation results use the structure and allowed values defined by the execution schema.