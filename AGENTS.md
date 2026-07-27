# AI Operator Entry Point

Before performing any repository inspection, analysis, validation, or modification:

1. Read `.flywheel/manifest.yaml`.
2. Resolve all paths relative to the repository root.
3. Open the exact file named by the manifest's `entrypoint` field.
4. Follow that startup protocol and its declared read order exactly.

The manifest is authoritative for locating the operating model. Its `locations` identify canonical artifact locations, and its ordered `required_files` list defines the complete required operating-artifact set for startup.

Reading `AGENTS.md`, `.flywheel/manifest.yaml`, the manifest entrypoint, and the startup-required operating artifacts is always authorized. It is not target-repository inspection or goal-directed work.

The repository artifacts are the durable source of operating context. Do not rely on prior conversation memory. Do not modify repository content until the mandatory startup protocol has completed and the required opening report has been produced.

If the manifest is missing, unreadable, invalid, or lacks an entrypoint, stop and report an Operating Model Defect. Do not search for or invent an alternate entrypoint.

All work must follow the active AI Flywheel mission, goal, governance, principles, lifecycle, evidence requirements, and readiness gates.
