# Adaptation

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

Adaptation changes the plan, implementation, tooling, configuration, guidance, or operating model in response to classified and evaluated evidence.

## Structured adaptation contract

Every material adaptation MUST use the structured adaptation model in `execution.schema.yaml`.

Each adaptation MUST include:

- A unique stable identifier using `ADAPT-NNN`.
- A permitted adaptation type.
- A concrete proposed change statement.
- Classification, evaluation, observation, and evidence references.
- Affected scope or artifacts.
- Rationale and intended effect.
- At least one alternative considered.
- Certainty and explicit uncertainty when provisional or disputed.
- Scope disposition.
- Approval and decision requirements.
- Disposition.
- Implementation, validation, persistence, and reuse statuses.

An adaptation is not a recommendation, decision, implementation action, validation result, persistence decision, or reuse result. Those concepts remain separate and are linked through explicit fields and later lifecycle stages.

## Permitted adaptation

Within an active goal, the operator MAY propose a reversible tactical change when it remains within scope, preserves governance, and does not require material approval.

Material adaptation requires a decision record and approval when it changes:

- Mission or goal intent.
- Architecture or primary technology.
- Dependency or security posture.
- Governance or validation strength.
- Public interfaces or compatibility commitments.
- Data handling or destructive behavior.

Scope expansion MUST use `scope_disposition: scope-expansion-approved`, `approval_required: true`, at least one approval reference, and a decision reference. Work that requires a new goal MUST use `scope_disposition: new-goal-required` and MUST remain not started.

## Certainty and support

- `ADAPTATION-PROVENANCE-001`: Every adaptation MUST reference at least one classification, evaluation, observation, and evidence item that resolve within the execution and its records.
- `ADAPTATION-CERTAINTY-001`: A provisional or disputed adaptation MUST include a nonempty uncertainty statement.
- `ADAPTATION-SUPPORT-001`: An adaptation MUST NOT be confirmed or approved solely from inconclusive, disputed, or uncertainty-only classifications without an additional supporting classification and evidence basis.
- `ADAPTATION-BOUNDARY-001`: A recommendation MUST NOT be represented as an approved adaptation, and an adaptation MUST NOT claim later-stage outcomes.

## Scope, approval, and decision rules

- `ADAPTATION-SCOPE-001`: Every affected scope item MUST remain within the active goal unless scope expansion is approved or a new goal is required.
- `ADAPTATION-APPROVAL-001`: When approval is required, approval references and a decision reference MUST exist and resolve before disposition may be `approved`.
- `ADAPTATION-DECISION-001`: A material adaptation MUST reference the decision that authorizes or rejects it.
- `ADAPTATION-IDENTITY-001`: Adaptation identifiers MUST be unique within the execution.

## Lifecycle boundaries

During Adapt activation and while an adaptation is merely proposed:

- `implementation_status` MUST be `not-started` or `not-applicable`.
- `validation_status` MUST be `not-started` or `not-applicable`.
- `persistence_status` MUST be `not-persisted`.
- `reuse_status` MUST be `not-assessed`.

Additional required rules:

- `ADAPTATION-IMPLEMENTATION-001`: An adaptation MUST NOT claim implementation before authorized implementation work occurs during Adapt.
- `ADAPTATION-VALIDATION-001`: An adaptation MUST NOT claim validation success before Validate completes with referenced validation evidence.
- `ADAPTATION-PERSISTENCE-001`: An adaptation MUST NOT be marked persisted before Persist completes.
- `ADAPTATION-REUSE-001`: An adaptation MUST NOT be marked reusable or not reusable before Reuse evaluates it.

## Adaptation sequence

1. Identify the observations and evaluations that triggered adaptation.
2. Resolve the classifications that justify the proposed change.
3. Record the structured adaptation with alternatives, scope, risk, certainty, approval, and decision requirements.
4. Obtain required decisions and approvals.
5. Apply only approved work that remains within the active goal.
6. Complete Adapt with the actual implementation disposition recorded.
7. Run affected validation during Validate.
8. Persist approved records and outcomes during Persist.
9. Evaluate reusable learning during Reuse.

## Adapt completion

Adapt MUST NOT be completed unless:

- At least one structured adaptation exists.
- The Adapt stage contains at least one adaptation reference.
- Every adaptation reference resolves.
- All provenance, scope, certainty, approval, decision, and lifecycle-boundary rules pass.
- The stage summary and timestamps exist.

When no adaptation is warranted, Adapt MUST be `not-applicable` with a concrete reason and the adaptations array MAY remain empty.

## Guardrails

Adaptation MUST NOT erase failure evidence, redefine acceptance criteria after the fact without approval, weaken a rule because implementation is difficult, or disguise unapproved scope expansion as tactical work.

When a framework defect is discovered, capture it separately from an application-repository defect. Fixing the framework may be part of the bootstrap mission or a dedicated framework-improvement goal.
