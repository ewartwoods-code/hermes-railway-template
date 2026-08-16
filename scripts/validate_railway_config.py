#!/usr/bin/env python3
"""Small dependency-free validator for the Railway fields this template owns."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    raise SystemExit(f"railway.json: {message}")


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: validate_railway_config.py SCHEMA CONFIG")

    schema_path, config_path = map(Path, sys.argv[1:])
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    config = json.loads(config_path.read_text(encoding="utf-8"))

    allowed_top = set(schema.get("properties", {}))
    unknown_top = set(config) - allowed_top
    if unknown_top:
        fail(f"unknown top-level fields: {sorted(unknown_top)}")

    expected = {
        "build": {
            "builder": "DOCKERFILE",
            "dockerfilePath": "Dockerfile",
        },
        "deploy": {
            "startCommand": "/opt/hermes/docker/entrypoint-dispatch.sh gateway run",
            "healthcheckPath": "/api/health",
            "healthcheckTimeout": 300,
            "restartPolicyType": "ON_FAILURE",
            "restartPolicyMaxRetries": 10,
        },
    }
    for section, fields in expected.items():
        actual = config.get(section)
        if not isinstance(actual, dict):
            fail(f"{section!r} must be an object")

        section_schema = schema["properties"][section].get("properties", {})
        unknown = set(actual) - set(section_schema)
        if unknown:
            fail(f"unknown {section} fields: {sorted(unknown)}")

        for key, value in fields.items():
            if actual.get(key) != value:
                fail(f"{section}.{key} must be {value!r}")

    print("railway.json: valid")


if __name__ == "__main__":
    main()
