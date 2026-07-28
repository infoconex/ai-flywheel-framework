# Validation

This document is normative. `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, and `SHALL NOT` define mandatory behavior.

Validate proves or disproves the outcome claimed for an implemented adaptation. Command completion alone is not proof.

## Structured validation contract

Every material validation MUST use the `validation_result` model in `execution.schema.yaml` and a stable `VAL-NNN` identifier unique within the execution.

A validation entry MUST identify:

- Whether it is a `planned` validation or an `executed` result.
- One or more target adaptations.
- At least one acceptance criterion or operating rule.
- The validation domain, severity, method, and immutable scope.
- The expected outcome and expected evidence established before execution.
- Eligibility or a concrete exclusion reason.
- The actual outcome, execution time, and collected evidence after execution.
- A finding and recovery action when validation fails.
- The prior validation it supersedes when a revised plan is required.

## Planning and activation

Before Validate becomes `in-progress`, every validation-eligible adaptation MUST have at least one planned validation entry. A planned entry uses:

- `phase: planned`
- `status: pending`
- `actual_outcome: null`
- `evidence_refs: []`
- `executed_at: null`

`VALIDATION-ELIGIBILITY-001`: An adaptation is validation-eligible only when it is approved when approval is required and its `implementation_status` is `completed`. Rejected, deferred, pending-approval, new-goal-required, not-started, or partially implemented adaptations MUST NOT pass validation.

`VALIDATION-COVERAGE-001`: Every eligible adaptation MUST be covered by at least one validation entry, and every validation entry MUST reference an existing adaptation.

`VALIDATION-BASIS-001`: Every validation MUST reference at least one acceptance criterion or operating rule and MUST define its method, scope, expected outcome, and expected evidence before execution.

## Execution and evidence

An executed validation MUST preserve the planned adaptation references, criterion and rule references, method, scope, expected outcome, and expected evidence. A revised validation MUST receive a new identity and use `supersedes_ref`; prior failed evidence MUST remain intact.

`VALIDATION-EVIDENCE-001`: A passed or failed validation MUST include evidence proving the actual outcome. A command exit code or assertion that a command ran is insufficient unless the expected outcome specifically concerns command execution.

`VALIDATION-RESULT-001`: `passed` requires an eligible implemented adaptation, a supported actual outcome, and sufficient evidence. `failed` requires evidence, a finding reference, and a recovery action. `not-applicable` requires `eligible: false` and a concrete exclusion reason.

`VALIDATION-STRENGTH-001`: After failure, the operator MUST NOT weaken the criterion, rule, scope, expected outcome, or expected evidence merely to obtain a pass. Any legitimate change requires a new validation entry, explicit rationale in the associated finding or decision, and `supersedes_ref` to the prior validation.

`VALIDATION-IDENTITY-001`: Validation identifiers MUST be unique within the execution.

## Adaptation status synchronization

`VALIDATION-SYNC-001`:

- An eligible adaptation with planned but unexecuted validations uses `validation_status: pending`.
- An adaptation uses `validation_status: passed` only when every required validation covering it has passed and none remains pending or failed.
- An adaptation uses `validation_status: failed` when any required validation covering it has failed and no later approved validation supersedes and passes it.
- An ineligible adaptation uses `validation_status: not-applicable` with corresponding not-applicable validation coverage when the reason must remain traceable.

## Validate completion

Validate MUST NOT be completed unless:

- At least one structured validation entry exists.
- The Validate stage references its validation entries.
- Every validation identifier and reference resolves.
- Every eligible adaptation has complete validation coverage.
- No required validation remains `pending`.
- Every passed or failed result has sufficient evidence.
- Every failed result has a finding and recovery action.
- Adaptation validation statuses agree with their covering validation results.
- Stage summary and timestamps exist.

If no adaptation is eligible for validation, Validate MUST be `not-applicable` with a concrete reason. Validation entries MAY record explicit exclusions when traceability is material.

## Lifecycle boundaries

Validate MUST NOT claim persistence or reuse. Persist cannot begin while any required validation is pending or failed without a formally authorized disposition. Failed validation returns work to classification or adaptation as required; it does not erase the failed result or silently rewrite the original validation basis.
