# Use the latest official Bun image
FROM oven/bun:latest

WORKDIR /app

# Set non-interactive for apt installations
ENV DEBIAN_FRONTEND=noninteractive
# Disable husky during install
ENV HUSKY=0

# Install build dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy EVERYTHING first to ensure all workspace package.json files,
# Catalogs, patches, and configurations are present for bun install.
# This avoids "Workspace not found" errors during the install phase.
COPY . .

# Install dependencies
RUN bun install

# Generate a dummy models-snapshot.ts if it's missing (project-specific build requirement)
RUN mkdir -p packages/cyberstrike/src/provider && \
    if [ ! -f packages/cyberstrike/src/provider/models-snapshot.ts ]; then \
    echo "export const snapshot = { models: [] } as const" > packages/cyberstrike/src/provider/models-snapshot.ts; \
    fi

# Build the application
RUN bun run build

# Expose the default port
EXPOSE 4096

# Set environment variables
ENV NODE_ENV=production
ENV PORT=4096
ENV CYBERSTRIKE_SERVER_PASSWORD=cyberstrike
ENV CYBERSTRIKE_SERVER_HOSTNAME=0.0.0.0

# Start command
CMD ["bun", "run", "--cwd", "packages/cyberstrike", "src/index.ts", "web", "--hostname", "0.0.0.0"]
