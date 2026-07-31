from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .logging import LogContext, StructuredLogger
from .repository import find_repository_root, iter_yaml_files, load_yaml, relative
from .validation import validate_repository


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="flywheel", description="Operate and validate repository-local AI Flywheel artifacts.")
    parser.add_argument("--root", type=Path, help="Repository root. Defaults to manifest discovery from the current directory.")
    parser.add_argument("--json", action="store_true", dest="as_json", help="Emit machine-readable JSON.")
    parser.add_argument("--log-file", type=Path, help="Append structured JSON-lines operational logs.")
    subcommands = parser.add_subparsers(dest="command", required=True)

    subcommands.add_parser("status", help="Show current durable Flywheel state.")
    subcommands.add_parser("validate", help="Validate manifest, required files, identities, and active references.")

    mission = subcommands.add_parser("mission", help="Mission operations.")
    mission_sub = mission.add_subparsers(dest="mission_command", required=True)
    mission_list = mission_sub.add_parser("list", help="List missions.")
    _add_filters(mission_list, include_mission=False)

    goal = subcommands.add_parser("goal", help="Goal operations.")
    goal_sub = goal.add_subparsers(dest="goal_command", required=True)
    goal_list = goal_sub.add_parser("list", help="List goals.")
    _add_filters(goal_list, include_mission=True)

    return parser


def _add_filters(parser: argparse.ArgumentParser, include_mission: bool) -> None:
    parser.add_argument("--id")
    parser.add_argument("--status")
    if include_mission:
        parser.add_argument("--mission-id")


def _root(args: argparse.Namespace) -> Path:
    return args.root.resolve() if args.root else find_repository_root()


def _emit(value: Any, as_json: bool) -> None:
    if as_json:
        print(json.dumps(value, indent=2, sort_keys=True))
    elif isinstance(value, dict):
        for key, item in value.items():
            print(f"{key}: {item}")
    elif isinstance(value, list):
        for item in value:
            if isinstance(item, dict):
                print(" | ".join(f"{key}={value}" for key, value in item.items()))
            else:
                print(item)
    else:
        print(value)


def _context(state: dict[str, Any]) -> LogContext:
    return LogContext(
        mission_id=state.get("active_mission"),
        goal_id=state.get("active_goal"),
        execution_id=state.get("active_execution"),
    )


def _status(root: Path) -> dict[str, Any]:
    state = load_yaml(root / ".flywheel" / "state.yaml").data
    if not isinstance(state, dict):
        raise ValueError(".flywheel/state.yaml must contain a mapping.")
    return state


def _list_missions(root: Path, args: argparse.Namespace) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    missions = root / ".flywheel" / "operations" / "missions"
    for path in sorted(missions.glob("*/mission.yaml")):
        data = load_yaml(path).data
        if not isinstance(data, dict):
            continue
        if args.id and data.get("id") != args.id:
            continue
        if args.status and data.get("status") != args.status:
            continue
        records.append({"id": data.get("id"), "status": data.get("status"), "title": data.get("title"), "path": relative(root, path)})
    return records


def _list_goals(root: Path, args: argparse.Namespace) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    missions = root / ".flywheel" / "operations" / "missions"
    for path in sorted(missions.glob("*/goals/*.yaml")):
        data = load_yaml(path).data
        if not isinstance(data, dict):
            continue
        if args.id and data.get("id") != args.id:
            continue
        if args.status and data.get("status") != args.status:
            continue
        if args.mission_id and data.get("mission_id") != args.mission_id:
            continue
        records.append({"id": data.get("id"), "mission_id": data.get("mission_id"), "status": data.get("status"), "title": data.get("title"), "path": relative(root, path)})
    return records


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        root = _root(args)
        state = _status(root)
        logger = StructuredLogger(log_file=args.log_file)
        context = _context(state)
        if args.command == "status":
            _emit(state, args.as_json)
            logger.emit("status.read", "Read durable Flywheel state.", context, root=str(root))
            return 0
        if args.command == "validate":
            report = validate_repository(root)
            result = {
                "passed": report.passed,
                "checked_files": report.checked_files,
                "issues": [issue.__dict__ for issue in report.issues],
            }
            _emit(result, args.as_json)
            logger.emit("validation.completed", "Repository validation completed.", context, passed=report.passed, issue_count=len(report.issues))
            return 0 if report.passed else 2
        if args.command == "mission" and args.mission_command == "list":
            _emit(_list_missions(root, args), args.as_json)
            return 0
        if args.command == "goal" and args.goal_command == "list":
            _emit(_list_goals(root, args), args.as_json)
            return 0
        raise RuntimeError("Unsupported command routing.")
    except Exception as error:
        print(f"flywheel: {error}", file=sys.stderr)
        return 1
