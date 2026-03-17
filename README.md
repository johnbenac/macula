# Macula

This repository publishes portable OurBox application images for the revived
Macula stack.

Current published apps:

- `macula-api`
- `macula-ui`

The repo follows the OurBox apps-repository pattern:

- `apps-manifest.json` is the publishing contract
- `.github/workflows/ci.yml` validates the manifest and build contexts
- `.github/workflows/publish-images.yml` publishes digest-addressable GHCR images

## Repository Shape

```text
.
├── .github/workflows/
├── apps/
│   ├── macula-api/
│   └── macula-ui/
├── scripts/
└── apps-manifest.json
```

## Current Implementation Notes

`macula-api` is a thin wrapper around the archived upstream backend image:

- base image: `kelpdigital/macula:a0532dd`
- startup command: `node /app/services/macula/lib/start.js`

`macula-ui` currently serves the revived static Svelte bundle that was built
from the archived Macula source after applying compatibility and read-only-mode
patches. It is served by Caddy and proxies the backend route families expected
by the browser app.

This repo is the app-image publisher layer. Catalog integration and renderer
work belong in the corresponding OurBox catalog and `sw-ourbox-os`.
