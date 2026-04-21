FROM oven/bun:latest

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV HUSKY=0

# Ku rakib git iyo qalabka kale (haddii loo baahdo)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Koobiyeey dhammaan faylasha ka hor rakibidda
COPY . .

# Haddii aad rabto inaad ka tagto faylasha aan loo baahnayn, adeegso .dockerignore (eeg hoos)

# Rakib qalabka
RUN bun install

# Haddii aad u baahan tahay inaad sameyso fayl models-snapshot.ts
RUN mkdir -p packages/cyberstrike/src/provider && \
    if [ ! -f packages/cyberstrike/src/provider/models-snapshot.ts ]; then \
    echo "export const snapshot = { models: [] } as const" > packages/cyberstrike/src/provider/models-snapshot.ts; \
    fi

# Dhismo (build)
RUN bun run build

EXPOSE 4096

ENV NODE_ENV=production
ENV PORT=4096
ENV CYBERSTRIKE_SERVER_PASSWORD=cyberstrike
ENV CYBERSTRIKE_SERVER_HOSTNAME=0.0.0.0

CMD ["bun", "run", "--cwd", "packages/cyberstrike", "src/index.ts", "web", "--hostname", "0.0.0.0"]
