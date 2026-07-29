# Reuse

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

Reuse evaluates validated execution learning and existing validated knowledge for safe future application. Reuse does not make unvalidated material authoritative.

## Activation

Reuse MUST NOT begin until Persist is `completed`, the persistence plan is terminal with `status: applied`, final whole-set verification passed, all durable references resolve, and no persistence blocker remains.

Before Reuse becomes `in-progress`, every material candidate learning item and every existing knowledge item considered for the execution MUST have a structured assessment conforming to `reuse-assessment.schema.yaml`. The Reuse stage MUST reference those assessments.

## Assessment scope

Each assessment MUST identify exactly one subject:

- A `candidate-learning` classification from the execution.
- An `existing-knowledge` artifact considered for the current or future work.

The assessment MUST record evidence and validation provenance, applicability, limitations, conflicts, duplicates, approval requirements, decision references, and a final disposition.

## Candidate-learning dispositions

A candidate-learning assessment uses one of:

- `promote`: Create a new validated knowledge artifact.
- `supersede`: Create a new validated knowledge artifact that references every prior knowledge item it replaces.
- `defer`: Preserve the candidate without promotion because validation, applicability, approval, or evidence is incomplete.
- `reject`: Record why the candidate is unsafe, unsupported, duplicate without value, or otherwise unsuitable.
- `not-reusable`: Record that the learning is execution-specific and should not be promoted.

`promote` and `supersede` require:

- A confirmed `validated-learning` classification.
- At least one validation reference whose final applicable result passed.
- Evidence references supporting the knowledge statement.
- Explicit applicability and limitations.
- Actionable reuse guidance.
- No unresolved conflict or duplicate.
- Required approval and decision references when the guidance is material, risk-bearing, governance-changing, destructive, or scope-expanding.

An observation, evaluation, finding, failed validation, rejected adaptation, or provisional classification MUST NOT be promoted directly.

## Existing-knowledge dispositions

An existing-knowledge assessment uses one of:

- `reused`: The item was applicable and informed the execution or a future instruction.
- `inapplicable`: The item was considered but its applicability conditions were not met.
- `revision-required`: New evidence conflicts with or materially narrows the item and a superseding candidate is required.
- `deprecated`: The item must no longer be used; deprecation requires a decision and approval when material.
- `not-considered`: Permitted only when the item was discovered after the relevant decision point or a concrete reason proves it could not materially apply.

Existing validated knowledge MUST NOT be reused outside its recorded applicability or contrary to its limitations.

## Duplicate, conflict, and supersession rules

Before promotion, search canonical knowledge for semantic duplicates and conflicts.

- A duplicate without material improvement MUST be rejected or linked as existing knowledge; it MUST NOT create a new knowledge identity.
- A materially improved replacement MUST use `supersede` and list every replaced knowledge ID.
- A conflict MUST be resolved by rejection, deferral, deprecation, or an approved superseding item. Conflicting validated items MUST NOT remain simultaneously active without an explicit scope distinction.
- Existing knowledge is immutable. Revisions use a new identity and `supersedes` linkage.

## Knowledge artifact requirements

A promoted knowledge artifact MUST conform to `knowledge.schema.yaml` and include:

- Stable identity and `status: validated`.
- Statement, applicability, limitations, and actionable reuse guidance.
- Evidence and validation references.
- Origin mission, goal, execution, classification, and reuse-assessment references.
- Validation timestamp and validating authority.
- Approval and decision references when required.
- Superseded knowledge references when applicable.

## Adaptation synchronization

`REUSE-SYNC-001`:

- An adaptation uses `reuse_status: reusable` only when at least one completed assessment links to it and results in `promote`, `supersede`, or `reused`.
- An adaptation uses `reuse_status: not-reusable` when every completed linked assessment results in `reject`, `not-reusable`, `inapplicable`, `defer`, or `revision-required` without a completed promotion.
- `reuse_status: not-assessed` blocks Reuse completion for an adaptation with validated learning or material reuse implications.

## Completion

Reuse may complete only when:

- At least one structured assessment exists, or the stage is `not-applicable` with a concrete reason proving no candidate or existing knowledge required assessment.
- Every required assessment is `completed` and has a final disposition.
- Every reference resolves.
- Every promotion or supersession has a schema-valid proposed knowledge artifact at its canonical path.
- Duplicate, conflict, approval, and supersession rules pass.
- Adaptation reuse statuses agree with assessments.
- The Reuse stage has references, summary, and timestamps.

Reuse completion does not itself complete the execution or goal. Execution completion additionally requires every lifecycle stage terminal, acceptance-criterion evidence, approvals, blockers resolved or formally disposed, an outcome, and a completion disposition.

## Required semantic rules

- `REUSE-ACTIVATE-001`: Reuse requires completed, verified Persist.
- `REUSE-ASSESS-001`: Every material candidate and considered existing knowledge item has one structured assessment.
- `REUSE-PROMOTE-001`: Promotion requires validated learning, passed validation provenance, evidence, applicability, limitations, and reuse guidance.
- `REUSE-DIRECT-001`: Observations and other unqualified records cannot be promoted directly.
- `REUSE-DUPLICATE-001`: Unresolved duplicates cannot create new knowledge.
- `REUSE-CONFLICT-001`: Unresolved conflicting knowledge cannot be promoted or reused.
- `REUSE-SUPERSEDE-001`: Revisions use new identities and explicit supersedes linkage.
- `REUSE-APPROVAL-001`: Material or risk-bearing knowledge requires the applicable decision and approval.
- `REUSE-EXISTING-001`: Existing knowledge use or rejection is recorded with applicability reasoning.
- `REUSE-SYNC-001`: Adaptation reuse status agrees with completed assessments.
- `REUSE-COMPLETE-001`: Reuse completes only when every required assessment and proposed knowledge artifact passes validation.
- `REUSE-HISTORY-001`: Knowledge and assessment history is immutable and preserved.
