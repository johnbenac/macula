#!/usr/bin/env bash
set -euo pipefail

IMAGE="local/macula-macula-ui:ci"
NAME="macula-ui-ci-smoke"
PORT="18080"

if [[ -n "${CONTAINER_RUNTIME:-}" ]]; then
  runtime="$CONTAINER_RUNTIME"
elif command -v docker >/dev/null 2>&1; then
  runtime="docker"
elif command -v podman >/dev/null 2>&1; then
  runtime="podman"
else
  echo "required command not found: docker or podman" >&2
  exit 1
fi
command -v curl >/dev/null 2>&1 || {
  echo "required command not found: curl" >&2
  exit 1
}

cleanup() {
  "$runtime" rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cleanup
"$runtime" run -d --rm --name "$NAME" -p "${PORT}:80" "$IMAGE" >/dev/null

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

health="$(curl -fsS "http://127.0.0.1:${PORT}/health")"
case "$health" in
  OK) ;;
  *)
    echo "unexpected /health response: $health" >&2
    exit 1
    ;;
esac

root_html="$(curl -fsS "http://127.0.0.1:${PORT}/")"
case "$root_html" in
  *"Macula | Your place for websites"*) ;;
  *)
    echo "root page did not include expected UI marker" >&2
    exit 1
    ;;
esac

printf '[%s] macula-ui runtime smoke passed\n' "$(date -Is)"
