# Isticmaal Bun image (CyberStrike wuxuu ku qoran yahay TypeScript)
FROM oven/bun:latest

# Deji goobta shaqada
WORKDIR /app

# Nuqul qaab-dhismeedka faylasha iyo rakibida
COPY package.json bun.lockb ./
RUN bun install

# Nuqul wakiilada iyo qaybaha kale
COPY . .

# Deji deegaanka (environment)
ENV NODE_ENV=production

# Amarka bilawga ee CyberStrike
CMD ["bun", "run", "cyberstrike"]
