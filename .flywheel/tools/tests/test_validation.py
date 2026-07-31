from pathlib import Path

import yaml

from flywheel.validation import validate_repository


def _write(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(yaml.safe_dump(value, sort_keys=False), encoding="utf-8")


def _fixture(tmp_path: Path) -> Path:
    root = tmp_path / "repo"
    _write(root / ".flywheel" / "manifest.yaml", {
        "schema_version": 1,
        "entrypoint": ".flywheel/operator.md",
        "required_files": [".flywheel/operator.md", ".flywheel/state.yaml"],
    })
    (root / ".flywheel" / "operator.md").write_text("operator", encoding="utf-8")
    _write(root / ".flywheel" / "state.yaml", {
        "schema_version": 1,
        "active_mission": "mission-one",
        "active_goal": "goal-one",
        "active_execution": None,
        "lifecycle_stage": None,
    })
    _write(root / ".flywheel" / "operations" / "missions" / "mission-one" / "mission.yaml", {
        "schema_version": 1,
        "id": "mission-one",
        "status": "active",
    })
    _write(root / ".flywheel" / "operations" / "missions" / "mission-one" / "goals" / "goal-one.yaml", {
        "schema_version": 1,
        "id": "goal-one",
        "mission_id": "mission-one",
        "status": "ready",
    })
    return root


def test_valid_minimum_fixture_passes(tmp_path: Path) -> None:
    report = validate_repository(_fixture(tmp_path))

    assert report.passed
    assert report.issues == ()


def test_missing_required_file_is_blocking(tmp_path: Path) -> None:
    root = _fixture(tmp_path)
    (root / ".flywheel" / "operator.md").unlink()

    report = validate_repository(root)

    assert not report.passed
    assert any(issue.code == "required.missing" for issue in report.issues)


def test_stage_without_execution_is_rejected(tmp_path: Path) -> None:
    root = _fixture(tmp_path)
    state_path = root / ".flywheel" / "state.yaml"
    state = yaml.safe_load(state_path.read_text(encoding="utf-8"))
    state["lifecycle_stage"] = "execute"
    _write(state_path, state)

    report = validate_repository(root)

    assert not report.passed
    assert any(issue.code == "state.stage_without_execution" for issue in report.issues)


def test_broken_active_goal_reference_is_rejected(tmp_path: Path) -> None:
    root = _fixture(tmp_path)
    (root / ".flywheel" / "operations" / "missions" / "mission-one" / "goals" / "goal-one.yaml").unlink()

    report = validate_repository(root)

    assert not report.passed
    assert any(issue.code == "state.goal_reference" for issue in report.issues)
