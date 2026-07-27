# Artifact Contracts

These contracts define the semantic expectations for Flywheel artifacts. The formal schemas in this directory are authoritative for single-artifact shape and allowed values. This document is authoritative for cross-artifact, repository-layout, transition, identity, and persistence invariants that JSON Schema cannot express.

A narrative requirement and its formal schema MUST agree. A discrepancy is an operating-model defect: startup validation MUST fail, no execution may be created, and no target-repository inspection may begin until the discrepancy is reconciled.

## Validator semantics

Schema validation SHALL use JSON Schema Draft 2020-12 semantics after parsing YAML 1.2. The validator MUST enforce `format`, including `date-time`. Timestamps MUST be RFC 3339 UTC values ending in `Z`. A repository-specific validator may use any implementation only if it produces equivalent results.

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
- Startup failure: `.flywheel/operations/records/startup-failures/<timestamp>-<failure-id>.yaml`

A path segment derived from an identifier MUST equal the identifier exactly. Duplicate identifiers, duplicate canonical paths, case-only collisions, or an artifact found outside its canonical location fail Operating Validation.

Record directories are lazy. Their absence is valid until the first record of that kind is persisted. Creating the first execution MUST create its canonical parent directory as part of the same durable update.

## Manifest

The manifest identifies schema version, framework name and version, the fixed canonical locations, the fixed startup entrypoint, required operating files, onboarding state, implementation state, and compatibility expectations. The manifest schema defines the non-removable minimum required set. Every listed file must exist exactly once as a regular file.

## State

State identifies readiness, phase, status, active mission, active goal, active execution when present, lifecycle stage, application-work permission, blockers, and the last durable update.

Required reference combinations are:

- An active goal requires an active mission.
- An active execution requires an active goal and active mission.
- A lifecycle stage requires an active execution.
- `status: active` requires an active execution.
- No active execution requires a null lifecycle stage.
- Non-ready readiness requires `application_missions_allowed: false`.
- A blocked state requires at least one blocker.

Every active reference must resolve to exactly one canonical artifact, and all reciprocal mission and goal identifiers must agree.

## Mission

A mission contains schema version, id, title, objective, status, success criteria, and ordered goal references. Mission success-criterion identifiers and goal references must each be unique. Every referenced goal must exist at the canonical path and declare the same mission id. Goal list order is the authoritative execution order unless dependencies require a later goal to remain blocked.

## Goal

A goal contains schema version, id, mission id, title, objective, status, acceptance criteria, and required-evidence mappings. Acceptance-criterion identifiers must be unique. Every acceptance criterion must have exactly one `evidence_required` mapping, every mapping must reference an existing criterion, and no unmapped or duplicate criterion references are permitted.

Dependency and blocker references must resolve to goals in the same mission unless an explicit cross-mission dependency contract is approved and persisted.

## Execution

An execution contains identifiers, status, intended outcome, acceptance-criterion snapshot, timestamps, all eight lifecycle stages, actions, observations, classifications, adaptations, validation results, evidence references, decisions, findings, blockers, outcome, and completion disposition.

The execution acceptance-criterion list must exactly equal the active goal's acceptance-criterion identifiers at execution creation. It is an immutable snapshot for that execution.

Exactly one lifecycle stage may be `in-progress`. Stages before it must be `completed` or `not-applicable`; stages after it must be `pending`. A terminal execution has no `pending` or `in-progress` stages, has a completion timestamp, outcome, rationale, and disposition, and cannot be active in state. A blocked execution contains at least one blocker.

An execution remains mutable while its status is `in-progress` or `blocked`. It becomes historical and immutable when it reaches any other terminal status. Corrections require a new superseding record; terminal execution content is not rewritten.

## Records

Evidence, decision, finding, and approval records use `record.schema.yaml` and are goal-owned. Knowledge uses `knowledge.schema.yaml` and is stored separately because it is reusable beyond the originating goal.

Approval authority is valid only when the named authority resolves to the configured human authority or an explicitly delegated role in governance. Approval evidence must identify the source interaction or durable artifact proving the decision.

## Durable update protocol

Repository files cannot provide a true multi-file transaction. Therefore "atomic" means the following deterministic compare-and-swap sequence:

1. Read and retain the current state file content hash or blob SHA.
2. Create the new execution or record at its canonical path using create-only semantics.
3. Re-read state and verify its hash is unchanged.
4. Update state using compare-and-swap semantics against the retained hash.
5. If state changed, do not overwrite it. Mark the newly created artifact orphaned through a startup-failure or finding record and stop for reconciliation.

Two operators must never overwrite each other's state. An active-execution collision is a blocker.

## Startup failure persistence

Recording a startup defect is a startup action, not goal-directed work. When Operating Validation fails before execution creation, the operator is authorized to create one immutable startup-failure record beneath `.flywheel/operations/records/startup-failures/`. It must contain the revision or branch observed, failed rules, artifact paths, evidence, recovery action, timestamp, and operator identity. State may be changed to `blocked` only when the existing state hash still matches and the failure directly prevents its active work from starting.

The operator may report or persist a proposed correction, but may not modify protected operating-model artifacts without human authorization or an active remediation goal.

## Revision consistency

At startup, the operator MUST resolve and report the immutable commit SHA when repository tooling makes it available. All artifacts used for one validation result must come from that same revision. State transitions and certification records must include that revision in their evidence references.

## Validation invariants

- Identifiers are stable and unique within their artifact type.
- References resolve and agree in both directions where both artifacts carry the relationship.
- Manifest locations and the entrypoint equal the canonical paths required by the manifest schema.
- Every manifest-required file exists.
- Terminal states require outcome and evidence.
- Goal completion requires evidence mapped to every acceptance criterion.
- Approved status requires approval evidence.
- Application missions require readiness `ready-for-missions`.
- Historical records are immutable except through explicit supersession metadata.
- Validation results use the structure and allowed values defined by the execution schema.
