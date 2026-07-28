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
- Approval requirement, approval status, and approval references.
- Decision reference when a decision exists or is required.
- Disposition.
- Implementation, validation, persistence, and reuse statuses.

An adaptation is not a recommendation, decision, implementation action, validation result, persistence decision, or reuse result. Those concepts remain separate and are linked through explicit fields and later lifecycle stages.

## Permitted adaptation

Within an active goal, the operator MAY propose a reversible tactical change when it remains within scope, preserves governance, and does not require material approval.

Material adaptation requires a decision record and approval before it may be approved or implemented when it changes:

- Mission or goal intent.
- Architecture or primary technology.
- Dependency or security posture.
- Governance or validation strength.
- Public interfaces or compatibility commitments.
- Data handling or destructive behavior.

A proposed or deferred adaptation MAY be recorded before required approval exists. In that state it MUST use `approval_required: true`, `approval_status: pending`, empty `approval_refs`, `decision_ref: null`, and `implementation_status: not-started`.

Scope expansion MUST use `scope_disposition: scope-expansion-approved` only after approval and an authorizing decision exist. Until then, record the adaptation as proposed or deferred within the current scope assessment, or use `scope_disposition: new-goal-required` when a separate goal is required. Work that requires a new goal MUST remain not started.

## Certainty and support

- `ADAPTATION-PROVENANCE-001`: Every adaptation MUST reference at least one classification, evaluation, observation, and evidence item that resolve within the execution and its records.
- `ADAPTATION-CERTAINTY-001`: A provisional or disputed adaptation MUST include a nonempty uncertainty statement.
- `ADAPTATION-SUPPORT-001`: An adaptation MUST NOT be confirmed or approved solely from inconclusive, disputed, or uncertainty-only classifications without an additional supporting classification and evidence basis.
- `ADAPTATION-BOUNDARY-001`: A recommendation MUST NOT be represented as an approved adaptation, and an adaptation MUST NOT claim later-stage outcomes.

## Scope, approval, and decision rules

- `ADAPTATION-SCOPE-001`: Every affected scope item MUST remain within the active goal unless scope expansion is approved or a new goal is required.
- `ADAPTATION-APPROVAL-001`: An approval-required adaptation MAY be proposed or deferred with `approval_status: pending`, no approval references, and no decision reference. Approval references and an authorizing decision MUST exist and resolve before disposition becomes `approved` or implementation begins.
- `ADAPTATION-APPROVAL-002`: When approval is not required, `approval_status` MUST be `not-required` and `approval_refs` MUST be empty.
- `ADAPTATION-REJECTION-001`: A rejected approval-required adaptation MUST use `approval_status: rejected`, reference the rejection or approval record, reference the decision, and remain unimplemented.
- `ADAPTATION-DECISION-001`: A material adaptation MUST reference the decision that authorizes or rejects it before it is approved, rejected, or implemented. A merely proposed or deferred adaptation awaiting that decision MAY use `decision_ref: null`.
- `ADAPTATION-IDENTITY-001`: Adaptation identifiers MUST be unique within the execution.

## Lifecycle boundaries

During Adapt activation and while an adaptation is merely proposed or deferred:

- `implementation_status` MUST be `not-started`.
- `validation_status` MUST be `not-started`.
- `persistence_status` MUST be `not-persisted`.
- `reuse_status` MUST be `not-assessed`.
- An approval-required adaptation MAY remain at `approval_status: pending`.

Additional required rules:

- `ADAPTATION-IMPLEMENTATION-001`: An adaptation MUST NOT enter implementation until disposition is `approved`; when approval is required, approval references and a decision reference MUST already resolve.
- `ADAPTATION-VALIDATION-001`: An adaptation MUST NOT claim validation success before Validate completes with referenced validation evidence.
- `ADAPTATION-PERSISTENCE-001`: An adaptation MUST NOT be marked persisted before Persist completes.
- `ADAPTATION-REUSE-001`: An adaptation MUST NOT be marked reusable or not reusable before Reuse evaluates it.

## Adaptation sequence

1. Identify the observations and evaluations that triggered adaptation.
2. Resolve the classifications that justify the proposed change.
3. Record the structured adaptation with alternatives, scope, risk, certainty, and approval and decision requirements.
4. When approval is required, persist the proposed adaptation as pending approval without fabricating approval or decision records.
5. Obtain required decisions and approvals.
6. Update the adaptation to approved or rejected using the resolved records.
7. Apply only approved work that remains within the active goal.
8. Complete Adapt with the actual implementation disposition recorded.
9. Run affected validation during Validate.
10. Persist approved records and outcomes during Persist.
11. Evaluate reusable learning during Reuse.

## Adapt completion

Adapt MUST NOT be completed unless:

- At least one structured adaptation exists.
- The Adapt stage contains at least one adaptation reference.
- Every adaptation reference resolves.
- All provenance, scope, certainty, approval, decision, and lifecycle-boundary rules pass.
- Any adaptation that began implementation is approved and has all required approval and decision references.
- Pending-approval adaptations remain proposed or deferred and not started.
- The stage summary and timestamps exist.

When no adaptation is warranted, Adapt MUST be `not-applicable` with a concrete reason and the adaptations array MAY remain empty.

## Guardrails

Adaptation MUST NOT erase failure evidence, redefine acceptance criteria after the fact without approval, weaken a rule because implementation is difficult, or disguise unapproved scope expansion as tactical work.

When a framework defect is discovered, capture it separately from an application-repository defect. Fixing the framework may be part of the bootstrap mission or a dedicated framework-improvement goal.
