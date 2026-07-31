from hashlib import sha256
from pathlib import Path

import pytest

from flywheel.repository import StaleWriteError, find_repository_root, load_yaml, write_yaml_compare_and_swap


def test_find_repository_root_from_nested_directory(tmp_path: Path) -> None:
    root = tmp_path / "repo"
    nested = root / "a" / "b"
    (root / ".flywheel").mkdir(parents=True)
    nested.mkdir(parents=True)
    (root / ".flywheel" / "manifest.yaml").write_text("schema_version: 1\n", encoding="utf-8")

    assert find_repository_root(nested) == root


def test_compare_and_swap_rejects_stale_write(tmp_path: Path) -> None:
    path = tmp_path / "state.yaml"
    path.write_text("value: one\n", encoding="utf-8")
    stale = sha256(b"value: stale\n").hexdigest()

    with pytest.raises(StaleWriteError):
        write_yaml_compare_and_swap(path, {"value": "two"}, stale)


def test_compare_and_swap_writes_when_identity_matches(tmp_path: Path) -> None:
    path = tmp_path / "state.yaml"
    path.write_text("value: one\n", encoding="utf-8")
    loaded = load_yaml(path)

    new_sha = write_yaml_compare_and_swap(path, {"value": "two"}, loaded.content_sha256)

    assert load_yaml(path).data == {"value": "two"}
    assert load_yaml(path).content_sha256 == new_sha
