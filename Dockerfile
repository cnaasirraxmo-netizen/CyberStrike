# Use the latest official Bun image for maximum compatibility
FROM oven/bun:latest

# Set working directory
WORKDIR /app

# Set non-interactive for apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (git is often required for dependencies/MCP)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy the entire project context
# This is crucial for Bun workspaces and Catalogs
COPY . .

# Install dependencies (without --frozen-lockfile to allow potential corrections if needed,
# although normally it's better, but we are troubleshooting resolution errors)
RUN bun install

# Generate a dummy models-snapshot.ts if it's missing (project-specific build requirement)
RUN mkdir -p packages/cyberstrike/src/provider && \
    if [ ! -f packages/cyberstrike/src/provider/models-snapshot.ts ]; then \
    echo "export const snapshot = { models: [] } as const" > packages/cyberstrike/src/provider/models-snapshot.ts; \
    fi

# Build the application (frontend and backend)
RUN bun run build

# Expose the default port
EXPOSE 4096

# Environment variables for production
ENV NODE_ENV=production
ENV PORT=4096
ENV CYBERSTRIKE_SERVER_PASSWORD=cyberstrike
ENV CYBERSTRIKE_SERVER_HOSTNAME=0.0.0.0

# Command to run the application in web mode
CMD ["bun", "run", "--cwd", "packages/cyberstrike", "src/index.ts", "web", "--hostname", "0.0.0.0"]
