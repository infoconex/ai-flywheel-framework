# AI Flywheel Framework

The official installable framework for the [AI Flywheel specification](https://github.com/Infoconex/ai-flywheel-spec).

> A loop repeats. A flywheel compounds.

## AI operator start here

Before performing any repository inspection, analysis, validation, or modification:

1. Read `.flywheel/manifest.yaml`.
2. Resolve all paths relative to the repository root.
3. Open the exact file named by the manifest's `entrypoint` field.
4. Follow that startup protocol without substituting another traversal order.

The manifest is the authoritative boundary for the installed operating model:

- `locations` identifies the canonical artifact locations.
- `required_files` defines the complete required operating-artifact set and its read order.
- `.flywheel/state.yaml` identifies the active mission, active goal, active execution, lifecycle stage, blockers, and readiness.

`AGENTS.md` and this README are discovery aids. They do not replace the manifest or its entrypoint. Reading these startup artifacts is always authorized and is not target-repository inspection or goal-directed work.

If the manifest is missing, unreadable, internally invalid, or does not identify an entrypoint, stop and report an Operating Model Defect. Do not search for or invent an alternative entrypoint.

## Purpose

This repository provides the canonical `.flywheel` structure used to initialize an AI Flywheel inside a target repository.

The installed framework begins in a manually operable state. Its default first mission consistently onboards the repository, captures human decisions, populates the operating model, and then designs and builds the repository-specific tools that will run future Flywheel operations.

The framework does not prescribe a programming language, runtime, architecture, coding style, testing library, or command interface. Those choices remain under the authority of the repository owner and are made through the bootstrap mission.

## Responsibilities

The framework is responsible for:

- Defining the canonical installed `.flywheel` structure
- Providing a consistent onboarding interview and persistence model
- Providing the default bootstrap mission and ordered goals
- Defining mission, goal, execution, evidence, and learning records
- Providing lifecycle, governance, validation, and operating guidance
- Defining minimum behavioral requirements for repository-specific tools
- Supporting manual operation until those tools can self-host the framework
- Remaining aligned with the AI Flywheel specification

## Installation model

A user copies the `.flywheel` directory and `AGENTS.md` from this repository into the root of a target repository. The AI operator begins with `.flywheel/manifest.yaml` and follows its declared entrypoint.

The first goals gather onboarding answers, inspect the repository, reconcile conflicts, and populate the configuration files. Later goals use that context to propose, build, validate, and prove the repository-specific Flywheel implementation.

## Relationship to the AI Flywheel ecosystem

| Repository | Responsibility |
|---|---|
| [ai-flywheel-spec](https://github.com/Infoconex/ai-flywheel-spec) | Defines the normative specification |
| **ai-flywheel-framework** | Provides the canonical installable `.flywheel` structure and bootstrap mission |
| Repository-specific implementation | Runs and evolves Flywheel operations using the language and standards selected during onboarding |
| Sample repositories | Demonstrate possible implementations without making them mandatory |

## Status

This repository is under active development. The current focus is proving that the framework contains enough context and guidance to onboard a repository and build the tools required to operate itself.

## License

Licensing information will be added as the project is formalized.
