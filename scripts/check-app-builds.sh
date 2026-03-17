#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v docker >/dev/null 2>&1; then
  CONTAINER_RUNTIME="docker"
elif command -v podman >/dev/null 2>&1; then
  CONTAINER_RUNTIME="podman"
else
  echo "required command not found: docker or podman" >&2
  exit 1
fi

command -v python3 >/dev/null 2>&1 || {
  echo "required command not found: python3" >&2
  exit 1
}

CONTAINER_RUNTIME="$CONTAINER_RUNTIME" python3 - <<'PY' "${ROOT}/apps-manifest.json" "${ROOT}"
import json
import os
import subprocess
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
root = Path(sys.argv[2])
collection_id = manifest["collection_id"]
runtime = os.environ["CONTAINER_RUNTIME"]

for app in manifest["apps"]:
    app_id = str(app["app_id"]).strip()
    source_path = root / str(app["source_path"]).strip()
    tag = f"local/{collection_id}-{app_id}:ci"
    subprocess.run(
        [runtime, "build", "--pull", "--tag", tag, str(source_path)],
        check=True,
    )
PY

CONTAINER_RUNTIME="$CONTAINER_RUNTIME" bash "${ROOT}/scripts/check-macula-ui-runtime-smoke.sh"

printf '[%s] app build smoke passed\n' "$(date -Is)"
