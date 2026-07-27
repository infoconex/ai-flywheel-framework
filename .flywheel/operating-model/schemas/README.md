# Artifact Contracts

These contracts define the minimum required shape and invariants for Flywheel artifacts. Tooling may implement formal JSON Schema, YAML validation, classes, or another mechanism, but it must enforce equivalent rules.

## Manifest

Must identify schema version, framework version, required operating files, locations, and compatibility expectations.

## State

Must identify readiness, phase, active mission, active goal, active execution when present, lifecycle stage, blockers, and last durable update. References must resolve to existing artifacts.

## Mission

Must contain id, title, objective, status, scope, constraints, success criteria, ordered goals, approval requirements, and completion evidence.

## Goal

Must contain id, mission id, title, objective, status, scope, exclusions, acceptance criteria, required evidence, validation, dependencies, approvals, and execution references.

## Execution

Must contain id, mission id, goal id, status, lifecycle-stage records, actions, observations, classifications, adaptations, validation results, evidence references, decisions, blockers, outcome, and timestamps.

## Evidence

Must contain id, evidence type, mission/goal/execution references, claim supported, source or method, actual result, timestamp, and storage/reference location.

## Decision

Must contain id, context references, statement, status, options, evidence, rationale, consequences, approval, and supersession information.

## Finding

Must contain id, classification, severity, observation, evidence, impact, disposition, owner, and related work.

## Knowledge

Must contain id, status, statement, applicability, limitations, evidence provenance, validation, reuse guidance, and supersession information.

## Validation invariants

- Identifiers are stable and unique within their artifact type.
- References resolve.
- Terminal states require outcome and evidence.
- Completion requires acceptance-criterion mapping.
- Approved status requires approval evidence.
- Application missions require readiness `ready-for-missions`.
- Historical records are immutable except for explicit correction or supersession metadata.