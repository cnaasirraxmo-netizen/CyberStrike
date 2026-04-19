# Use the official Bun image
FROM oven/bun:1.1.20 as base
WORKDIR /app

# Copy root package files
COPY package.json bun.lock ./

# Copy all package.json files to maintain workspace structure
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

# Install all dependencies
RUN bun install

# Copy the rest of the application
COPY . .

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

# Install runtime dependencies
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
