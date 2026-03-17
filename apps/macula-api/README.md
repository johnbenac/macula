# Macula API Image

This image is a thin wrapper around the archived Macula backend image.

Runtime contract:

- base image: `kelpdigital/macula:a0532dd`
- command: `node /app/services/macula/lib/start.js`
- backend health: `/healthcheck`

This wrapper exists so the OurBox app publisher owns the image reference and
can evolve the backend contract without asking downstream deployers to carry a
manual command override.
