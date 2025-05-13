FROM node:22-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json files first (for better caching)
COPY shared/package*.json ./shared/
COPY services/user-service/package*.json ./services/user-service/

# Install dependencies in shared and service directories
WORKDIR /app/shared
RUN npm ci

WORKDIR /app/services/user-service
RUN npm ci

# Copy the rest of the application code
WORKDIR /app
COPY shared ./shared
COPY services/user-service ./services/user-service

# Build the application
WORKDIR /app/services/user-service
RUN npm run build

# ---------- Production Stage ----------
FROM node:22-alpine
WORKDIR /app

# Copy built app and dependencies from builder stage
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/services/user-service ./services/user-service

# Set working directory to service directory
WORKDIR /app/services/user-service

# Only install production dependencies
RUN npm ci --only=production

EXPOSE 3005
CMD [ "npm", "run", "dev" ]