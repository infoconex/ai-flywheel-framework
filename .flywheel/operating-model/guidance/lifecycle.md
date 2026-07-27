# AI Flywheel Lifecycle

Every execution follows and records all eight lifecycle stages. Stages may iterate, but none may be omitted.

Each stage record must include a status, summary, timestamps, and relevant references. Allowed stage statuses are `pending`, `in-progress`, `completed`, and `not-applicable`. A `not-applicable` stage requires a concrete reason.

## 1. Execute

Perform only work authorized by the active goal, using the approved plan and constraints.

## 2. Observe

Capture actual results, evidence, unexpected behavior, failures, environmental facts, and human feedback.

## 3. Evaluate

Compare observations with acceptance criteria, expected outcomes, governance, and validation requirements.

## 4. Classify

Classify material outcomes such as defects, findings, decisions, improvements, risks, uncertainties, and validated learning.

## 5. Adapt

Change the application, Flywheel tools, configuration, guidance, plan, or scope when justified. Scope expansion requires approval or a new goal. When no adaptation is warranted, record the stage as `not-applicable` and explain why.

## 6. Validate

Run required checks and collect evidence proving the claimed outcome. Validation must establish more than command execution.

## 7. Persist

Update state and store execution records, evidence, decisions, findings, approvals, and learning in canonical locations.

## 8. Reuse

Identify relevant validated knowledge for later work and make new validated learning discoverable. When no reusable knowledge applies or results, record the stage as `not-applicable` with a reason.

## Completion rule

An execution may close only after every stage is `completed` or justified as `not-applicable`. A goal may complete only after all acceptance-criterion IDs map to sufficient evidence, required validation passes, blockers are resolved or formally disposed, required approvals exist, and the completion state is persisted.