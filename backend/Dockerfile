# =============================================================================
# AI House Planner - Backend Dockerfile
# Node.js 20 LTS / Alpine
# =============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Builder (installs all deps including devDependencies)
# ---------------------------------------------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first for layer caching
COPY package*.json ./

# Install all dependencies (needed to build/transpile if applicable)
RUN npm ci

# Copy source code
COPY . .

# ---------------------------------------------------------------------------
# Stage 2: Production image (lean, no devDependencies)
# ---------------------------------------------------------------------------
FROM node:20-alpine AS production

# Install dumb-init for proper PID 1 signal handling
RUN apk add --no-cache dumb-init

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser  -S nodejs -u 1001

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application source from builder
COPY --from=builder /app/src ./src

# Create uploads directory with correct ownership
RUN mkdir -p uploads && chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose API port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget -qO- http://localhost:3000/api/health || exit 1

# Use dumb-init as entrypoint for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "src/app.js"]
