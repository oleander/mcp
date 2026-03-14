# syntax=docker/dockerfile:1

# ── shared builder ────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
RUN npm install -g npm@latest

# ── plex ──────────────────────────────────────────────────────────────────────
# Installed from GitHub — no published npm package exists.
# The package ships TypeScript source only, so we clone, install all deps,
# compile with tsc, prune devDeps, then copy the result into the final image.
FROM builder AS plex-build
RUN apk add --no-cache git \
 && git clone --depth 1 https://github.com/niavasha/plex-mcp-server.git /opt/plex-mcp-server \
 && cd /opt/plex-mcp-server \
 && npm install \
 && npm run build \
 && npm prune --production \
 && rm -rf .git src .github docs \
 && apk del git

FROM node:22-alpine AS plex
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=plex-build /opt/plex-mcp-server /opt/plex-mcp-server
USER appuser
ENTRYPOINT ["node", "/opt/plex-mcp-server/build/index.js"]
