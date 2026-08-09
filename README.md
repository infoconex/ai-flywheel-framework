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

The framework has its own implementation-neutral installer. Installing the framework does not require Python and does not install or invoke the Python CLI or any other runtime implementation.

For release `2026.08.08`, the public Windows entry point is:

```powershell
irm https://raw.githubusercontent.com/Infoconex/ai-flywheel-framework/v2026.08.08/install.ps1 | iex
```

The public `install.ps1` is a lightweight `Invoke-Expression`-safe launcher. It downloads the reviewed canonical installer from `scripts/install-framework.ps1` and runs it in its own script scope.

The installer:

- resolves the target Git repository root;
- downloads `ai-flywheel-framework-2026.08.08.zip` and its `.sha256` sidecar from release `v2026.08.08`;
- verifies the published checksum;
- rejects unsafe archive paths or content outside `.flywheel`;
- verifies the package manifest identifies framework version `2026.08.08`;
- stages and hash-verifies the framework before publication into the repository;
- records installation provenance in `.flywheel/installation.yaml`;
- verifies the installed package files byte-for-byte; and
- refuses to overwrite an existing `.flywheel` installation.

A successful initial installation changes only `.flywheel/`. It does not start onboarding or any lifecycle execution. `AGENTS.md` remains a repository discovery aid and is not required for the installed framework because the canonical startup boundary is `.flywheel/manifest.yaml`.

For release-candidate testing from a framework checkout, build the package with:

```powershell
.\tools\package-framework.ps1
```

Then invoke the canonical installer with `-PackagePath` against a test Git repository. The local regression gate performs this flow automatically:

```powershell
.\tools\test-framework-installer.ps1
```

## Release model

The framework, its installer, its package, and its release tag share one CalVer release identity. For this release:

```text
Framework manifest: 2026.08.08
Release tag:        v2026.08.08
Package:            ai-flywheel-framework-2026.08.08.zip
Checksum:           ai-flywheel-framework-2026.08.08.zip.sha256
Installer target:   2026.08.08
```

Framework validity is established before publication through the framework certification and release-validation process. The installer is responsible for proving that the exact published artifact was acquired and installed faithfully; it does not re-certify the framework's schemas or operating semantics.

## Relationship to the AI Flywheel ecosystem

| Repository | Responsibility |
|---|---|
| [ai-flywheel-spec](https://github.com/Infoconex/ai-flywheel-spec) | Defines the normative specification |
| **ai-flywheel-framework** | Provides the canonical installable `.flywheel` structure, framework release, and implementation-neutral framework installer |
| Language-specific CLI/implementation | Optionally ensures a compatible framework exists, installs its own runtime dependencies, and operates the Flywheel |
| Repository-specific implementation | Runs and evolves Flywheel operations using the language and standards selected during onboarding |
| Sample repositories | Demonstrate possible implementations without making them mandatory |

## Status

This repository is under active development. The current focus is proving that the framework contains enough context and guidance to onboard a repository and build the tools required to operate itself.

## License

Licensing information will be added as the project is formalized.
