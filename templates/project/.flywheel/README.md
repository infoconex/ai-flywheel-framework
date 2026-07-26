# Generated AI Flywheel Control Plane

This directory is the source layout installed into a consuming repository.

- `manifest.yaml` identifies installed framework assets and versions.
- `state.yaml` points to the current mission, goal, and execution.
- `operating-model/config/` contains structured project-specific operating rules.
- `operating-model/guidance/` contains operator and procedural guidance.
- `operations/missions/<mission>/goals/<goal>/executions/<execution>/` preserves operational history.
- `operations/records/` contains promoted durable records.
- `operations/knowledge/` contains validated reusable knowledge.

Executions belong to goals. Evidence remains local to an execution unless promoted by the operating model.
