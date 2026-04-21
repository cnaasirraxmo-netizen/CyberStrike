FROM oven/bun:latest

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV HUSKY=0

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

COPY package.json ./
RUN bun install

COPY . .

RUN mkdir -p packages/cyberstrike/src/provider && \
    if [ ! -f packages/cyberstrike/src/provider/models-snapshot.ts ]; then \
    echo "export const snapshot = { models: [] } as const" > packages/cyberstrike/src/provider/models-snapshot.ts; \
    fi

RUN bun run build

EXPOSE 4096

ENV NODE_ENV=production
ENV PORT=4096
ENV CYBERSTRIKE_SERVER_PASSWORD=cyberstrike
ENV CYBERSTRIKE_SERVER_HOSTNAME=0.0.0.0

CMD ["bun", "run", "--cwd", "packages/cyberstrike", "src/index.ts", "web", "--hostname", "0.0.0.0"]
