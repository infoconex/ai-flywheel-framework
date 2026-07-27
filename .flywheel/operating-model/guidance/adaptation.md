# Adaptation

Adaptation changes the plan, implementation, tooling, or operating model in response to evaluated evidence.

## Permitted adaptation

Within an active goal, the operator may make reversible tactical changes when they remain within scope, preserve governance, and do not require material approval.

Material adaptation requires a decision record and approval when it changes:

- Mission or goal intent.
- Architecture or primary technology.
- Dependency or security posture.
- Governance or validation strength.
- Public interfaces or compatibility commitments.
- Data handling or destructive behavior.

## Adaptation sequence

1. Identify the observation that triggered adaptation.
2. Classify the finding.
3. Describe the proposed change and alternatives.
4. Evaluate scope, risk, and approval requirements.
5. Record the decision.
6. Apply the approved change.
7. Re-run affected validation.
8. Persist reusable learning.

## Guardrails

Adaptation must not erase failure evidence, redefine acceptance criteria after the fact without approval, or weaken a rule simply because implementation is difficult.

When a framework defect is discovered, capture it separately from the repository application defect. Fixing the framework may be part of the bootstrap mission or a dedicated framework-improvement goal.