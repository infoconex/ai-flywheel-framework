from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator
from jsonschema.exceptions import SchemaError

from .repository import iter_yaml_files, load_yaml, relative


@dataclass(frozen=True)
class ValidationIssue:
    code: str
    path: str
    message: str
    severity: str = "error"


@dataclass(frozen=True)
class ValidationReport:
    checked_files: int
    issues: tuple[ValidationIssue, ...]

    @property
    def passed(self) -> bool:
        return not any(issue.severity in {"error", "blocker"} for issue in self.issues)


def _required_paths(manifest: dict[str, Any]) -> list[str]:
    required = manifest.get("required_files", [])
    result: list[str] = []
    for item in required:
        if isinstance(item, str):
            result.append(item)
        elif isinstance(item, dict) and isinstance(item.get("path"), str):
            result.append(item["path"])
    return result


def validate_repository(root: Path) -> ValidationReport:
    issues: list[ValidationIssue] = []
    checked = 0
    manifest_path = root / ".flywheel" / "manifest.yaml"
    manifest = load_yaml(manifest_path).data
    checked += 1
    if not isinstance(manifest, dict):
        return ValidationReport(checked, (ValidationIssue("manifest.type", relative(root, manifest_path), "Manifest must be a mapping.", "blocker"),))

    entrypoint = manifest.get("entrypoint")
    if not isinstance(entrypoint, str) or not entrypoint:
        issues.append(ValidationIssue("manifest.entrypoint", relative(root, manifest_path), "Manifest entrypoint is missing or invalid.", "blocker"))
    elif not (root / entrypoint).is_file():
        issues.append(ValidationIssue("manifest.entrypoint.missing", entrypoint, "Manifest entrypoint does not exist.", "blocker"))

    for required_path in _required_paths(manifest):
        checked += 1
        if not (root / required_path).is_file():
            issues.append(ValidationIssue("required.missing", required_path, "Manifest-required file is missing.", "blocker"))

    schemas_dir = root / ".flywheel" / "operating-model" / "schemas"
    schemas: dict[str, dict[str, Any]] = {}
    for schema_path in iter_yaml_files(schemas_dir):
        checked += 1
        loaded = load_yaml(schema_path).data
        if not isinstance(loaded, dict):
            issues.append(ValidationIssue("schema.type", relative(root, schema_path), "Schema must be a mapping."))
            continue
        try:
            Draft202012Validator.check_schema(loaded)
        except SchemaError as error:
            issues.append(ValidationIssue("schema.invalid", relative(root, schema_path), error.message))
            continue
        schemas[schema_path.name] = loaded

    state_path = root / ".flywheel" / "state.yaml"
    if state_path.is_file():
        checked += 1
        state = load_yaml(state_path).data
        _validate_state(root, state, issues)

    _validate_identity_paths(root, issues)
    return ValidationReport(checked, tuple(issues))


def _validate_state(root: Path, state: Any, issues: list[ValidationIssue]) -> None:
    if not isinstance(state, dict):
        issues.append(ValidationIssue("state.type", ".flywheel/state.yaml", "State must be a mapping.", "blocker"))
        return
    mission_id = state.get("active_mission")
    goal_id = state.get("active_goal")
    execution_id = state.get("active_execution")
    stage = state.get("lifecycle_stage")
    if execution_id is None and stage is not None:
        issues.append(ValidationIssue("state.stage_without_execution", ".flywheel/state.yaml", "lifecycle_stage must be null when active_execution is null."))
    if execution_id is not None and stage is None:
        issues.append(ValidationIssue("state.execution_without_stage", ".flywheel/state.yaml", "lifecycle_stage is required when active_execution is set."))
    if mission_id and goal_id:
        goal_path = root / ".flywheel" / "operations" / "missions" / str(mission_id) / "goals" / f"{goal_id}.yaml"
        if not goal_path.is_file():
            issues.append(ValidationIssue("state.goal_reference", relative(root, goal_path), "Active goal reference does not resolve.", "blocker"))
    if mission_id and goal_id and execution_id:
        execution_path = root / ".flywheel" / "operations" / "records" / str(mission_id) / str(goal_id) / "executions" / f"{execution_id}.yaml"
        if not execution_path.is_file():
            issues.append(ValidationIssue("state.execution_reference", relative(root, execution_path), "Active execution reference does not resolve.", "blocker"))


def _validate_identity_paths(root: Path, issues: list[ValidationIssue]) -> None:
    missions_root = root / ".flywheel" / "operations" / "missions"
    for path in iter_yaml_files(missions_root):
        data = load_yaml(path).data
        if not isinstance(data, dict) or not isinstance(data.get("id"), str):
            continue
        if path.name in {"mission.yaml"}:
            expected = path.parent.name
        elif path.parent.name == "goals":
            expected = path.stem
        else:
            continue
        if data["id"] != expected:
            issues.append(ValidationIssue("identity.filename", relative(root, path), f"Artifact id {data['id']!r} does not match path identity {expected!r}."))
