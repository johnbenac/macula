# Macula UI Image

This image serves the revived Macula browser UI with Caddy.

It includes:

- the static Svelte bundle under `site/`
- a same-origin proxy contract for Macula backend routes
- a dedicated `/health` endpoint for CI and platform health checks

Proxied routes:

- `/api/*` -> `/hosting/api/*`
- `/hosting/api/*`
- `/hosting/withIpfs/*`
- `/hosting/withSubdomain/*`
- `/ipfs/*`
- `/ipfs_api/*`
