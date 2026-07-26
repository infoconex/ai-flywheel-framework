# AI Flywheel Standard Operating Procedure

## Execute Through Goals

All repository changes must be performed through an approved goal within an approved mission. Discussion may identify decisions and candidate work, but it does not authorize implementation.

## Executions

Each attempt to advance a goal is recorded beneath that goal in `executions/`. Executions are append-oriented and preserve failed or incomplete attempts. Completing an execution does not by itself complete its goal.

## Lifecycle

For each execution:

1. Execute the scoped work.
2. Observe results and failures.
3. Evaluate evidence against success criteria.
4. Classify defects, findings, decisions, risks, exceptions, and learning.
5. Adapt code, framework assets, or this procedure only when justified.
6. Validate deterministically where possible.
7. Persist durable records and validated knowledge.
8. Reuse only validated learning.

## Promotion

Execution-local observations and evidence remain with the execution. Records that require durable tracking are promoted to `.flywheel/operations/records/`. Reusable validated learning is promoted to `.flywheel/operations/knowledge/`.

## Branch and Review

Use a non-main branch. Open a pull request for review. Only the human authority may approve the initial merge.

## Failure Handling

Do not hide failed attempts. Record the failure, its classification, the resulting adaptation, and the new validation result.
