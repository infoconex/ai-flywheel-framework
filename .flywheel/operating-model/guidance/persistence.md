# Persistence and Reuse

Persistence makes execution state and learning durable across sessions.

## Persist before stopping

Before ending a work session, the operator must update:

- Active execution record.
- Goal status and lifecycle stage.
- State file.
- Evidence and decision records created during the session.
- Findings, blockers, assumptions, and unresolved questions.
- Repository or Flywheel context changed by confirmed information.

A conversational summary is not a substitute for repository persistence.

## Records versus knowledge

Records preserve what happened during a specific mission, goal, and execution. Knowledge contains validated, reusable information expected to help future work.

Do not promote an observation directly to knowledge. Promotion requires:

1. Supporting evidence.
2. Evaluation of applicability and limitations.
3. Validation or repeated confirmation.
4. A clear reuse instruction.
5. Provenance back to the originating records.

## Knowledge maintenance

Knowledge may be `candidate`, `validated`, `deprecated`, or `superseded`. New evidence must not silently overwrite prior knowledge. Preserve history and link replacements.

## Reuse

At startup and goal planning, search validated knowledge for applicable guidance. Record whether it was reused, rejected as inapplicable, or exposed a need for revision.