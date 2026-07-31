# AI Flywheel Tools

This directory contains the approved repository-local Python CLI implementation for operating and validating AI Flywheel artifacts.

## Requirements

- CPython 3.11 or later
- PyYAML
- jsonschema
- pytest for tests

## Install for development

```bash
cd .flywheel/tools
python -m pip install -e ".[test]"
```

## Commands

```bash
python -m flywheel status
python -m flywheel validate
python -m flywheel mission list
python -m flywheel mission list --status active
python -m flywheel goal list --mission-id establish-ai-flywheel-operations
python -m flywheel goal list --status ready
```

Use `--json` for machine-readable output and `--log-file <path>` to append structured JSON-lines events.

The CLI discovers the repository root by searching the current directory and its parents for `.flywheel/manifest.yaml`. Use `--root <path>` to select a repository explicitly.

## Current boundary

The initial implementation slice provides deterministic repository discovery, status reporting, required-file and reference validation, filtered mission and goal listing, compare-and-swap YAML persistence support, and structured logging. The remaining approved CRUD, execution, evidence, approval, and readiness commands must be completed before Goal 004 can close.

Core operation does not require GitHub Actions or another hosted service. Direct artifact operation remains the documented fallback.
