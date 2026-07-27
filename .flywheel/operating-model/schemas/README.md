# Artifact Contracts

These contracts define the semantic expectations for Flywheel artifacts. The formal schemas in this directory are authoritative for required shape and allowed values. This document adds cross-artifact invariants that schemas alone may not express.

A narrative requirement and its formal schema MUST agree. A discrepancy is an operating-model defect: startup validation MUST fail, no execution may be created, and no repository inspection may begin until the discrepancy is reconciled.

## Manifest

Must identify schema version, framework name and version, required operating files, canonical locations, entrypoint, onboarding state, implementation state, and compatibility expectations.

## State

Must identify readiness, phase, status, active mission, active goal, active execution when present, lifecycle stage, application-work permission, blockers, and the last durable update. References must resolve to existing artifacts. A blocked state must contain at least one blocker.

## Mission

Must contain schema version, id, title, objective, status, success criteria, and ordered goal references. Constraints and other mission governance fields are included when applicable. Every referenced goal must exist and declare the same mission id.

## Goal

Must contain schema version, id, mission id, title, objective, status, and acceptance criteria. Required evidence and dependency or blocker references are included when applicable. The goal filename must match its id, and its mission id must match the containing and active mission.

## Execution

Must contain id, mission id, goal id, status, lifecycle-stage records, actions, observations, classifications, adaptations, validation results, evidence references, decisions, blockers, outcome, and timestamps as defined by the execution schema and execution guidance.

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
- References resolve and agree in both directions where both artifacts carry the relationship.
- Manifest locations resolve relative to the repository root.
- Every required file exists.
- Terminal states require outcome and evidence.
- Completion requires acceptance-criterion mapping.
- Approved status requires approval evidence.
- Application missions require readiness `ready-for-missions`.
- Historical records are immutable except for explicit correction or supersession metadata.
