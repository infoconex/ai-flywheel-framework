# Adaptive Onboarding Process

Onboarding prepares the Flywheel to operate future missions. It does not perform application work.

## Two contexts

Onboarding must keep separate:

- Target repository context: purpose, application technologies, architecture, build, tests, standards, constraints, and domain knowledge.
- Flywheel implementation context: language, runtime, architecture, tests, storage, logging, command interface, dependencies, and deployment of the operating tools.

Target repository technologies are evidence, not automatic Flywheel implementation choices.

## Process

1. Inspect the repository before interviewing the human.
2. Record direct observations with source and confidence.
3. Load existing configuration and documentation.
4. Identify contradictions, unknowns, decisions, and approval requirements.
5. Execute applicable questions from `interview.yaml` one at a time.
6. Explain why each question matters and present discovered options when useful.
7. Persist each confirmed answer immediately.
8. Reconcile answers with repository evidence.
9. Record unresolved items as unknown, deferred, or blocked rather than guessing.
10. Validate onboarding completeness against the next readiness gate.

## Question behavior

Do not ask for information already established by strong evidence unless confirmation is required. Prefer contextual questions such as:

> I found .NET and PowerShell in the repository. These describe available technologies but do not determine the Flywheel implementation. Which runtimes are acceptable for the Flywheel tools?

## Provenance

Every value must include an origin:

- `observed`: directly inspected.
- `provided`: supplied by the human.
- `inferred`: reasoned from evidence and awaiting confirmation when material.
- `defaulted`: supplied by framework policy.
- `approved`: explicitly accepted by an authorized human.

## Completion

Onboarding is complete only when required repository context, governance, validation expectations, capability requirements, and unresolved decisions are sufficient to design the Flywheel tools. Tool implementation and application work remain separate later stages.