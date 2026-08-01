# Programmatic Operations Contract

## Scope

This contract defines how an implementation may manage Flywheel artifacts through commands, APIs, libraries, or equivalent machine interfaces. It is implementation-neutral and does not prescribe a programming language or command syntax.

Artifact-governed operation and programmatic operation are separate capability claims. Valid artifacts do not prove that all lifecycle actions are programmatically supported.

## Required operation families

A complete programmatic-operations implementation provides declared operations for:

- missions;
- goals;
- executions;
- lifecycle stages;
- typed records and references;
- approvals;
- state transitions;
- validation; and
- transition recovery.

Implementations may support a subset, but machine-readable capability declarations must not advertise unsupported operations.

## Operation definition

Each operation must define:

- `id`: stable operation identifier;
- `inputs`: required and optional inputs;
- `preconditions`: facts that must hold before execution;
- `artifacts_read`: canonical artifacts read;
- `artifacts_written`: canonical artifacts created or replaced;
- `approval`: whether durable prior approval is required;
- `validation`: checks required before commit;
- `postconditions`: facts guaranteed after success;
- `idempotency`: result of retrying the same intent;
- `atomicity`: atomic commit or recoverable transition strategy;
- `success_result`: deterministic machine-readable success shape; and
- `failure_results`: deterministic categories for rejected, conflicted, blocked, or failed operations.

## Preconditions and postconditions

Operations must reject invalid transitions before modifying canonical state. Preconditions include active-reference consistency, allowed status transitions, dependency satisfaction, approval availability, and lifecycle ordering.

A successful operation must leave every affected artifact schema-valid and mutually consistent. State must agree with the mission, goal, execution, and lifecycle records it references.

## Approval boundary

An operation that requires human approval must resolve a durable approval record before changing canonical artifacts. A conversational statement that has not been persisted and linked is not sufficient authorization.

Approval consumption must be traceable to the operation result. Retrying an approved idempotent operation must not require duplicate approval unless the intended transition changed.

## Atomicity

Operations that write multiple artifacts must use one of these strategies:

1. stage, validate, and atomically replace all affected artifacts under a repository lock; or
2. persist a transition record before the first canonical mutation and provide deterministic resume or rollback.

A process interruption must never silently create a partially completed lifecycle transition.

## Idempotency

Every mutating operation must define an intent identity or equivalent retry key. A repeated operation with the same intent must either:

- return the already completed result without a second mutation;
- safely resume the incomplete transition; or
- reject the request as a deterministic conflict when the original intent cannot be reproduced.

## Validation

Before commit, implementations must validate:

- schemas and formats;
- identity and filename rules;
- record placement and parent references;
- state consistency;
- lifecycle ordering and terminal requirements;
- referenced evidence and approvals;
- acceptance-criterion evidence mappings where required; and
- capability-specific postconditions.

## Recovery

Transition recovery must identify the last durable step, affected artifacts, expected hashes or revisions, and the only allowed next actions. Recovery must not infer missing intent from surrounding files.

## Certification

Programmatic-operations certification requires positive and negative execution through the declared machine interface. Direct editing of canonical artifacts may establish artifact-governed conformance but cannot establish programmatic-operations conformance.
