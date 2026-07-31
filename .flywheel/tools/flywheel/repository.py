from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
from typing import Any, Iterable

import yaml


class FlywheelError(RuntimeError):
    """Base error for deterministic CLI failures."""


class RepositoryNotFoundError(FlywheelError):
    pass


class StaleWriteError(FlywheelError):
    pass


@dataclass(frozen=True)
class LoadedYaml:
    path: Path
    data: Any
    content_sha256: str


def find_repository_root(start: Path | None = None) -> Path:
    current = (start or Path.cwd()).resolve()
    for candidate in (current, *current.parents):
        if (candidate / ".flywheel" / "manifest.yaml").is_file():
            return candidate
    raise RepositoryNotFoundError("No .flywheel/manifest.yaml found in this directory or its parents.")


def load_yaml(path: Path) -> LoadedYaml:
    raw = path.read_bytes()
    data = yaml.safe_load(raw.decode("utf-8"))
    return LoadedYaml(path=path, data=data, content_sha256=sha256(raw).hexdigest())


def write_yaml_compare_and_swap(path: Path, data: Any, expected_sha256: str) -> str:
    current_raw = path.read_bytes() if path.exists() else b""
    current_sha = sha256(current_raw).hexdigest()
    if current_sha != expected_sha256:
        raise StaleWriteError(
            f"Stale write rejected for {path}: expected {expected_sha256}, actual {current_sha}."
        )
    rendered = yaml.safe_dump(data, sort_keys=False, allow_unicode=True).encode("utf-8")
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_bytes(rendered)
    temporary.replace(path)
    return sha256(rendered).hexdigest()


def iter_yaml_files(directory: Path) -> Iterable[Path]:
    if not directory.exists():
        return []
    return sorted(path for path in directory.rglob("*.yaml") if path.is_file())


def relative(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()
