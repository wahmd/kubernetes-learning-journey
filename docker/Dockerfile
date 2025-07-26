# Multi-stage Dockerfile for Node.js REST API
# Stage 1: Build dependencies and prepare application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (for better layer caching)
COPY app/package*.json ./

# Install ALL dependencies (including devDependencies for testing)
RUN npm ci --only=production --silent

# Copy source code
COPY app/ .

# Run tests to ensure application works
RUN npm install --only=dev --silent && npm test

# Stage 2: Production image
FROM node:18-alpine AS production

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

# Set working directory
WORKDIR /app

# Copy only production dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
COPY --from=builder /app/app.js ./
COPY --from=builder /app/package.json ./

# Create logs directory and set permissions
RUN mkdir -p /app/logs && \
    chown -R nodeuser:nodejs /app

# Switch to non-root user
USER nodeuser

# Expose port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "const http = require('http'); \
                 http.get('http://localhost:3000/health', (res) => { \
                   process.exit(res.statusCode === 200 ? 0 : 1); \
                 }).on('error', () => process.exit(1));"

# Set production environment
ENV NODE_ENV=production

# Start the application
CMD ["node", "app.js"]