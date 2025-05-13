# ---------- Build Stage ----------
FROM node:22-alpine AS builder

WORKDIR /app

# Copy shared package first
COPY shared ./shared

# Copy user-service package
COPY services/user-service/package*.json ./
RUN npm ci

COPY services/user-service ./

RUN npm run build

# ---------- Development Stage ----------
FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app .

RUN npm ci

EXPOSE 3005

CMD [ "npm", "run", "dev" ]