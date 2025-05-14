#!/bin/bash
# This script generates Dockerfiles for all services in the services directory

# Configuration
TEMPLATE_FILE="./scripts/dockerfile-template.txt"
OUTPUT_DIR="./services"
SHARED_DIR="./shared"
SERVICES_DIR="./services"

# Create template file if it doesn't exist
mkdir -p ./scripts
cat >"$TEMPLATE_FILE" <<'EOL'
FROM node:22-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json files first (for better caching)
COPY shared/package*.json ./shared/
COPY services/{{SERVICE_NAME}}/package*.json ./services/{{SERVICE_NAME}}/

# Install dependencies in shared and service directories
WORKDIR /app/shared
RUN npm ci

WORKDIR /app/services/{{SERVICE_NAME}}
RUN npm ci

# Copy the rest of the application code
WORKDIR /app
COPY shared ./shared
COPY services/{{SERVICE_NAME}} ./services/{{SERVICE_NAME}}

# Build the application
WORKDIR /app/services/{{SERVICE_NAME}}
RUN npm run build

# ---------- Production Stage ----------
FROM node:22-alpine
WORKDIR /app

# Copy built app and dependencies from builder stage
COPY --from=builder /app/shared ./shared
COPY --from=builder /app/services/{{SERVICE_NAME}} ./services/{{SERVICE_NAME}}

# Set working directory to service directory
WORKDIR /app/services/{{SERVICE_NAME}}

# Only install production dependencies
RUN npm ci --only=production

EXPOSE {{PORT}}
CMD [ "npm", "run", "dev" ]
EOL

echo "🚀 Dockerfile template created at $TEMPLATE_FILE"

# Service port mapping - customize as needed
declare -A SERVICE_PORTS=(
    # Add mappings for all your services here
    ["analytics-reporting-service"]=3000
    ["audit-logging-service"]=3001
    ["billing-lifecycle-management-service"]=3002
    ["billing-service"]=3003
    ["collection-management-service"]=3004
    ["complaint-grievance-management-service"]=3005
    ["consumer-document-management-service"]=3006
    ["consumer-lifecycle-service"]=3007
    ["consumer-service"]=3008
    ["dynamic-configuration-management-service"]=3009
    ["git-location-management-service"]=3010
    ["iot-device-management-service"]=3011
    ["meter-management-inventory-service"]=3012
    ["meter-reading-management-service"]=3013
    ["notification-communication-service"]=3014
    ["payment-gateway-integration-service"]=3015
    ["policy-management-service"]=3016
    ["policy-rule-engine-service"]=3017
    ["policy-service"]=3018
    ["revenure-forecasting-leakage-detection-service"]=3019
    ["scheme-subsidy-management-service"]=3020
    ["service-request-management-service"]=3021
    ["tariff-management-service"]=3022
    ["third-party-integration-gateway-service"]=3023
    ["user-identity-access-management-service"]=3024
    ["user-service"]=3025
    ["workflow-approval-service"]=3026
)

# Generate Dockerfiles for each service
for service_dir in "$SERVICES_DIR"/*; do
    if [ -d "$service_dir" ] && [ "$(basename "$service_dir")" != "infra" ] && [ "$(basename "$service_dir")" != "shared" ]; then
        service_name=$(basename "$service_dir")

        # Get port from mapping or use default
        port=${SERVICE_PORTS[$service_name]:-3000}

        # Create Dockerfile
        output_file="$service_dir/Dockerfile"

        # Generate Dockerfile from template
        sed -e "s/{{SERVICE_NAME}}/$service_name/g" -e "s/{{PORT}}/$port/g" "$TEMPLATE_FILE" >"$output_file"

        echo "✅ Generated Dockerfile for $service_name with port $port"
    fi
done

echo "✨ Done! Generated Dockerfiles for all services."
