from __future__ import annotations

import json
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class LogContext:
    mission_id: str | None = None
    goal_id: str | None = None
    execution_id: str | None = None


class StructuredLogger:
    def __init__(self, name: str = "flywheel", log_file: Path | None = None) -> None:
        self._logger = logging.getLogger(name)
        self._logger.setLevel(logging.INFO)
        self._logger.handlers.clear()
        console = logging.StreamHandler()
        console.setFormatter(logging.Formatter("%(levelname)s %(message)s"))
        self._logger.addHandler(console)
        self._json_file = log_file

    def emit(self, event: str, message: str, context: LogContext, **fields: Any) -> None:
        payload = {
            "event": event,
            "message": message,
            "mission_id": context.mission_id,
            "goal_id": context.goal_id,
            "execution_id": context.execution_id,
            **fields,
        }
        self._logger.info("%s: %s", event, message)
        if self._json_file is not None:
            self._json_file.parent.mkdir(parents=True, exist_ok=True)
            with self._json_file.open("a", encoding="utf-8") as stream:
                stream.write(json.dumps(payload, sort_keys=True) + "\n")
