# Use the official Bun image
FROM oven/bun:1.1.20 as base
WORKDIR /app

# Copy the entire project first to ensure all workspace package.json files
# and bun configuration (including catalogs) are present for installation.
COPY . .

# Install all dependencies
RUN bun install

# Generate a dummy models-snapshot.ts if it doesn't exist
RUN if [ ! -f packages/cyberstrike/src/provider/models-snapshot.ts ]; then \
    mkdir -p packages/cyberstrike/src/provider && \
    echo "export const snapshot = { models: [] } as const" > packages/cyberstrike/src/provider/models-snapshot.ts; \
    fi

# Build the frontend and backend
RUN bun run build

# Final stage
FROM oven/bun:1.1.20-slim
WORKDIR /app

# Install runtime dependencies (like git)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy built artifacts and necessary files from base
COPY --from=base /app /app

# Expose the port
EXPOSE 4096

# Set environment variables
ENV NODE_ENV=production
ENV PORT=4096
ENV CYBERSTRIKE_SERVER_PASSWORD=cyberstrike
ENV CYBERSTRIKE_SERVER_HOSTNAME=0.0.0.0

# Start the server using the web command
CMD ["bun", "run", "--cwd", "packages/cyberstrike", "src/index.ts", "web", "--hostname", "0.0.0.0"]
