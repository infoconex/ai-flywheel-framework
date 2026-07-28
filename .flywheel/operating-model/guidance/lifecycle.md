# AI Flywheel Lifecycle

Every execution follows and records all eight lifecycle stages. Stages may iterate internally, but none may be omitted or entered out of order.

Each stage record must include a status, summary, timestamps, and relevant references. Allowed stage statuses are `pending`, `in-progress`, `completed`, and `not-applicable`. A `not-applicable` stage requires a concrete reason.

A stage may become `in-progress` only when every predecessor is `completed` or `not-applicable`, every successor is `pending`, and state identifies the same active execution and lifecycle stage.

## 1. Execute

Perform only work authorized by the active goal, using the approved plan and constraints.

## 2. Observe

Capture actual results, evidence, unexpected behavior, failures, environmental facts, and human feedback.

Observations must use the structured observation model. A direct observation must not contain an inferred cause, conclusion, classification, recommendation, adaptation, validation conclusion, persist decision, or reuse decision.

Observe may complete only when at least one observation exists, complete observations reference evidence, the execution and stage contain required evidence references, and the stage summary and timestamps are present.

## 3. Evaluate

Compare observations with acceptance criteria, expected outcomes, governance, and validation requirements.

Material evaluation conclusions must use structured evaluation entries and remain traceable to observations and evidence. Evaluate may interpret supported facts and identify limitations, but it must not introduce unsupported facts or prematurely assert later-stage classifications, adaptations, persistence decisions, or reuse decisions.

Evaluate may complete only when at least one structured evaluation exists, the Evaluate stage references its outputs, and all observation and evidence references resolve. When no material evaluation exists, mark the stage `not-applicable` with a concrete reason.

## 4. Classify

Classify material outcomes such as defects, findings, decisions, improvements, risks, uncertainties, failures, and validated learning.

Classifications must use the structured classification model and remain traceable to evaluations and evidence. Certainty and uncertainty must be explicit, related classifications must be linked, and decision, finding, and validation references must satisfy the type-specific rules in `classifications.md`.

Classify may complete only when at least one structured classification exists, the Classify stage references its outputs, and all classification semantic and reference checks pass. When no material classification exists, mark the stage `not-applicable` with a concrete reason.

## 5. Adapt

Define and apply justified changes to the plan, implementation, tooling, configuration, guidance, or operating model.

Every material adaptation must use the structured adaptation model and remain traceable to classifications, evaluations, observations, and evidence. Affected scope, intended effect, alternatives, certainty, approval requirements, decision references, disposition, and downstream lifecycle statuses must be explicit.

At Adapt activation, proposed work must not claim implementation, validation, persistence, or reuse outcomes. Scope expansion requires approval and a decision, while work requiring a new goal must remain not started.

Adapt may complete only when at least one structured adaptation exists, the Adapt stage references its outputs, and all provenance, scope, certainty, approval, decision, and lifecycle-boundary checks pass. When no adaptation is warranted, mark the stage `not-applicable` with a concrete reason.

## 6. Validate

Run required checks and collect evidence proving the claimed outcome. Validation must establish more than command execution.

## 7. Persist

Update state and store execution records, evidence, decisions, findings, approvals, and learning in canonical locations.

## 8. Reuse

Identify relevant validated knowledge for later work and make new validated learning discoverable. When no reusable knowledge applies or results, record the stage as `not-applicable` with a reason.

## Durable transitions

Every transition that changes both an existing execution and state must follow the dual-artifact compare-and-swap, final-pair verification, and partial-transition recovery sequence in `execution-model.md`.

## Timestamp rules

Execution and lifecycle timestamps must satisfy the semantic validation rules defined in `execution-model.md`:

- Execution start is no later than any stage start.
- Stage completion is no earlier than stage start.
- A successor stage does not start before its predecessor completes.
- State durable-update time is not earlier than the transition instant.

Violations must be rejected even when timestamp strings independently satisfy schema format validation.

## Completion rule

An execution may close only after every stage is `completed` or justified as `not-applicable`. A goal may complete only after all acceptance-criterion IDs map to sufficient evidence, required validation passes, blockers are resolved or formally disposed, required approvals exist, and the completion state is persisted.
