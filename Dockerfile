# Stage 1: Build Stage
FROM dhi.io/node:26-alpine-dev AS builder

WORKDIR /app

# Install necessary build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all project files
COPY . .

# Build the Next.js application
RUN npm run build

#RUN npm run test


# Stage 2: Production Stage
FROM dhi.io/node:26-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# DHI runtime images run as nonroot (UID 65532) by default
# Copy necessary files from builder stage with proper ownership
COPY --chown=65532:65532 --from=builder /app/.next/standalone ./
COPY --chown=65532:65532 --from=builder /app/.next/static ./.next/static
COPY --chown=65532:65532 --from=builder /app/public ./public

# Create writable directories for Next.js cache and temp files
RUN mkdir -p /app/.next/cache /app/tmp && chown -R 65532:65532 /app

EXPOSE 3000

CMD ["node", "server.js"]