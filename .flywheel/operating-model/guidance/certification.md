# Framework Certification

This document is normative. A repository MUST complete certification before transitioning to `ready-for-missions`.

## Authorization boundary

Full certification is goal-directed work. It may begin only when an active goal explicitly authorizes the certification scenarios and an execution has been created or resumed. A cold-start startup check may be requested independently, but it ends after the required opening report and execution decision; it does not authorize comprehensive framework review, fixture mutation, repository validation, or implementation validation.

Explicit human direction authorizes the requested action only within the current persisted mission and goal. It does not implicitly create a goal, change scope, bypass approvals, or modify state.

## Certification purpose

Certification proves that the installed Flywheel can be discovered, operated, recovered, validated, and approved without prior conversational context.

## Required certification scenarios

1. **Context-free startup:** A new AI session receives only the immutable repository revision and instruction to operate it. It reads the repository-root operator entry document when present, follows its manifest-first direction, reads the manifest entrypoint, produces the fixed opening report, and selects the correct execution action.
2. **First execution:** With no prior execution records, the operator creates the initial execution and updates state using the durable update protocol before repository inspection.
3. **Resume:** With an interrupted execution, the operator resumes the persisted lifecycle stage without creating a duplicate execution.
4. **Missing artifact recovery:** An isolated fixture with a required file missing causes a deterministic stop and exact diagnostic.
5. **Broken reference recovery:** An isolated fixture with an invalid active reference causes a deterministic stop without guessing.
6. **Approval boundary:** An approval-required action is not performed before recorded approval.
7. **Lifecycle completeness:** All eight lifecycle stages are persisted, including reasons for any `not-applicable` stage.
8. **Evidence completeness:** Every acceptance criterion maps to traceable evidence.
9. **Proving mission:** A representative non-destructive mission completes using the installed operating tools or approved manual procedures.
10. **Self-hosting:** The Flywheel uses its own validated mission, goal, execution, evidence, and validation capabilities to complete certification.

## Fixture isolation

Failure fixtures MUST run in a disposable copy, worktree, temporary branch, or in-memory representation pinned to the same source revision. Certification MUST NOT delete or corrupt canonical operating artifacts to prove failure handling. Each fixture declares its source revision, mutation, expected result, cleanup method, and actual result. The fixture environment must be removed or reset after evidence is captured.

## Certification record

Certification MUST produce a record containing:

- Immutable repository commit SHA and Flywheel version.
- AI system or operator identity.
- Exact cold-start prompt.
- Active certification mission, goal, and execution identifiers.
- Scenario fixture definitions, results, and evidence references.
- Validator implementation, JSON Schema draft, YAML version, and format-enforcement behavior.
- Known limitations.
- Findings and corrective actions.
- Human acceptance or rejection.

## Approval authority

The approving human MUST be the repository owner identified by governance or a delegate explicitly named in a durable approval record. The approval record must include the authorization basis and source evidence. An unidentified or assumed human is not sufficient.

## Passing rule

Certification passes only when every required scenario passes, no blocking invariant violation remains, the proving mission succeeds, and an authorized human approves the certification record.

A failed certification MUST leave readiness as `not-ready-for-missions` or `degraded` and create or update corrective goals. When failure occurs before an execution can be created, it must use the startup-failure persistence contract instead.
