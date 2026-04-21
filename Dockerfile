# --- Build Stage ---
FROM oven/bun:latest AS builder

WORKDIR /app

# Set non-interactive for apt installations
ENV DEBIAN_FRONTEND=noninteractive
# Disable husky during install
ENV HUSKY=0

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy root configuration files for dependency resolution
COPY package.json bun.lock bunfig.toml ./

# Copy all workspace package.json files to maintain structure for caching
COPY packages/sdk/js/package.json ./packages/sdk/js/
COPY packages/script/package.json ./packages/script/
COPY packages/app/package.json ./packages/app/
COPY packages/function/package.json ./packages/function/
COPY packages/console/resource/package.json ./packages/console/resource/
COPY packages/console/app/package.json ./packages/console/app/
COPY packages/console/function/package.json ./packages/console/function/
COPY packages/console/core/package.json ./packages/console/core/
COPY packages/console/mail/package.json ./packages/console/mail/
COPY packages/plugin/package.json ./packages/plugin/
COPY packages/util/package.json ./packages/util/
COPY packages/ui/package.json ./packages/ui/
COPY packages/slack/package.json ./packages/slack/
COPY packages/cyberstrike/package.json ./packages/cyberstrike/
COPY packages/enterprise/package.json ./packages/enterprise/

# Copy patches (required for bun install)
COPY patches ./patches

# Install dependencies
RUN bun install

# Copy the rest of the application source
COPY . .

# Generate a dummy models-snapshot.ts if it's missing
RUN mkdir -p packages/cyberstrike/src/provider && \
    if [ ! -f packages/cyberstrike/src/provider/models-snapshot.ts ]; then \
    echo "export const snapshot = { models: [] } as const" > packages/cyberstrike/src/provider/models-snapshot.ts; \
    fi

# Build the application
RUN bun run build

# --- Runtime Stage ---
FROM oven/bun:1-slim

WORKDIR /app

# Set non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy built artifacts and source for running
COPY --from=builder /app /app

# Expose the default port
EXPOSE 4096

# Environment variables
ENV NODE_ENV=production
ENV PORT=4096
ENV CYBERSTRIKE_SERVER_PASSWORD=cyberstrike
ENV CYBERSTRIKE_SERVER_HOSTNAME=0.0.0.0

# Start command
CMD ["bun", "run", "--cwd", "packages/cyberstrike", "src/index.ts", "web", "--hostname", "0.0.0.0"]
