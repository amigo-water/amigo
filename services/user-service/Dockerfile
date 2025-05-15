# ---------- Builder Stage ----------
FROM node:22-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json files first (for better caching)
COPY shared/package*.json ./shared/
COPY services/user-service/package*.json ./services/user-service/
COPY package*.json ./

# Install root dependencies first if needed
RUN npm ci --only=production

# Install dependencies in shared and service directories
WORKDIR /app/shared
RUN npm ci --only=production

WORKDIR /app/services/user-service
RUN npm ci

# Copy application source code
WORKDIR /app
COPY tsconfig.json ./
COPY shared ./shared
COPY services/user-service ./services/user-service

# Build the application
WORKDIR /app/services/user-service
RUN npm run build

# ---------- Production Stage ----------
FROM node:22-alpine
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY shared/package*.json ./shared/
COPY services/user-service/package*.json ./services/user-service/

# Install production dependencies
RUN npm ci --only=production
WORKDIR /app/shared
RUN npm ci --only=production
WORKDIR /app/services/user-service
RUN npm ci --only=production

# Copy built dist directory from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/services/user-service/node_modules ./services/user-service/node_modules

# Expose the service port
EXPOSE 3025

# Use a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Start the application
CMD [ "npm", "run", "start" ]