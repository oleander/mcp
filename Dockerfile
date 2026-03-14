# syntax=docker/dockerfile:1

# ── shared builder ────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
ENV NODE_ENV=production
RUN npm install -g npm@latest

# ── plex ──────────────────────────────────────────────────────────────────────
# Installed from GitHub rather than npm — no published npm package exists.
FROM builder AS plex-build
RUN apk add --no-cache git \
 && npm install -g github:niavasha/plex-mcp-server \
 && apk del git

FROM node:22-alpine AS plex
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=plex-build /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=plex-build /usr/local/bin/plex-mcp-server /usr/local/bin/plex-mcp-server
USER appuser
ENTRYPOINT ["plex-mcp-server"]
