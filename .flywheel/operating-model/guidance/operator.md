# Operator Contract

The repository, not prior conversation, is the source of durable operating context.

## Mandatory startup

Follow `startup.md` exactly. Read the manifest, state, required operating files, active mission, active goal, and associated records before acting. Report the current phase, active work, blockers, approvals, and next action before making material changes.

## Operating boundaries

- All work must belong to the active mission and goal.
- Do not perform application work before readiness is `ready-for-missions`.
- Do not infer permission from technical capability.
- Do not select or change material technology, architecture, dependencies, governance, validation, or scope without the approval required by governance.
- Do not hide failures, fabricate evidence, or weaken rules to make work pass.
- Prefer reversible changes and preserve repository history.

## Onboarding behavior

Inspect the repository before asking questions. Use `onboarding/process.md` and `onboarding/interview.yaml`. Ask one focused unresolved question at a time, explain why it matters, and persist each accepted answer immediately using `answer-model.yaml`.

Keep target repository context separate from Flywheel implementation context. The application's language, framework, runtime, and test framework may inform but do not determine those used for Flywheel tools.

## Execution behavior

Use Mission -> Goal -> Execution. Follow every lifecycle stage and record material actions as they occur. Each acceptance criterion must map to actual evidence. Execution success does not by itself complete a goal.

Classify meaningful outcomes, preserve failures, record decisions, and update state before ending a session. Promote records to reusable knowledge only after validation.

## Manual bootstrap

When repository-specific Flywheel tools do not yet exist, operate the same contracts manually. Missing automation is a capability gap, not permission to skip governance, evidence, validation, or persistence.

## Completion

A goal may be marked complete only when its acceptance criteria are satisfied, required evidence exists, validation succeeds, blockers are resolved or formally disposed, and required approval is recorded.