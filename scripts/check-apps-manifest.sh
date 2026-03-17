#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - <<'PY' "$ROOT"
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
manifest_path = root / "apps-manifest.json"

if not manifest_path.is_file():
    raise SystemExit(f"missing apps-manifest.json: {manifest_path}")

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
if manifest.get("schema") != 1 or manifest.get("kind") != "ourbox-apps-collection":
    raise SystemExit("apps-manifest.json must declare schema=1 and kind=ourbox-apps-collection")

collection_id = str(manifest.get("collection_id", "")).strip()
if collection_id != "macula":
    raise SystemExit(f"collection_id must be 'macula', got {collection_id!r}")

apps = manifest.get("apps")
if not isinstance(apps, list) or len(apps) != 2:
    raise SystemExit("apps-manifest.json must declare exactly two apps: macula-api and macula-ui")

expected = {
    "macula-api": {
        "source_path": "apps/macula-api",
        "image_repo": "ghcr.io/johnbenac/macula/macula-api",
        "required": [
            "apps/macula-api/Dockerfile",
            "apps/macula-api/README.md",
        ],
    },
    "macula-ui": {
        "source_path": "apps/macula-ui",
        "image_repo": "ghcr.io/johnbenac/macula/macula-ui",
        "required": [
            "apps/macula-ui/Dockerfile",
            "apps/macula-ui/Caddyfile",
            "apps/macula-ui/README.md",
            "apps/macula-ui/site/index.html",
            "apps/macula-ui/site/macula.json",
        ],
    },
}

seen = set()
for app in apps:
    app_id = str(app.get("app_id", "")).strip()
    display_name = str(app.get("display_name", "")).strip()
    source_path = str(app.get("source_path", "")).strip()
    image_repo = str(app.get("image_repo", "")).strip()
    default_tag = str(app.get("default_tag", "")).strip()

    if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", app_id):
        raise SystemExit(f"invalid app_id: {app_id!r}")
    if app_id not in expected:
        raise SystemExit(f"unexpected app_id: {app_id}")
    if app_id in seen:
        raise SystemExit(f"duplicate app_id: {app_id}")
    seen.add(app_id)
    if not display_name or default_tag != "latest":
        raise SystemExit(f"app {app_id!r} must declare non-empty display_name and default_tag=latest")
    if source_path != expected[app_id]["source_path"]:
        raise SystemExit(f"app {app_id!r} source_path mismatch: {source_path}")
    if image_repo != expected[app_id]["image_repo"]:
        raise SystemExit(f"app {app_id!r} image_repo mismatch: {image_repo}")

missing = []
for spec in expected.values():
    for rel in spec["required"]:
        if not (root / rel).exists():
            missing.append(rel)
if missing:
    raise SystemExit("missing required repo paths:\n- " + "\n- ".join(missing))

print("apps manifest validation passed")
PY

printf '[%s] apps manifest validation passed\n' "$(date -Is)"
