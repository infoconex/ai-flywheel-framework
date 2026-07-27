# Framework Certification

This document is normative. A repository MUST complete certification before transitioning to `ready-for-missions`.

## Certification purpose

Certification proves that the installed Flywheel can be discovered, operated, recovered, validated, and approved without prior conversational context.

## Required certification scenarios

1. **Context-free startup:** A new AI session receives only the repository location and instruction to operate it. It discovers the entry point, reads required artifacts, produces the fixed opening report, and selects the correct execution action.
2. **First execution:** With no prior execution records, the operator creates the initial execution and updates state before repository inspection.
3. **Resume:** With an interrupted execution, the operator resumes the persisted lifecycle stage without creating a duplicate execution.
4. **Missing artifact recovery:** A controlled fixture with a required file missing causes a deterministic stop and exact diagnostic.
5. **Broken reference recovery:** A controlled invalid active reference causes a deterministic stop without guessing.
6. **Approval boundary:** An approval-required action is not performed before recorded approval.
7. **Lifecycle completeness:** All eight lifecycle stages are persisted, including reasons for any `not-applicable` stage.
8. **Evidence completeness:** Every acceptance criterion maps to traceable evidence.
9. **Proving mission:** A representative non-destructive mission completes using the installed operating tools or approved manual procedures.
10. **Self-hosting:** The Flywheel uses its own validated mission, goal, execution, evidence, and validation capabilities to complete certification.

## Certification record

Certification MUST produce a record containing:

- Repository revision and Flywheel version.
- AI system or operator identity.
- Exact cold-start prompt.
- Scenario results and evidence references.
- Validator results.
- Known limitations.
- Findings and corrective actions.
- Human acceptance or rejection.

## Passing rule

Certification passes only when every required scenario passes, no blocking invariant violation remains, the proving mission succeeds, and an authorized human approves the certification record.

A failed certification MUST leave readiness as `not-ready-for-missions` or `degraded` and create or update corrective goals.