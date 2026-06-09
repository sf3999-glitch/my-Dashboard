# =============================================================================
# AI House Planner - Admin Dashboard Dockerfile
# React + Vite / nginx
# =============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Build the React app
# ---------------------------------------------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files for layer caching
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy source files
COPY . .

# Build the production bundle
RUN npm run build

# ---------------------------------------------------------------------------
# Stage 2: Serve with nginx
# ---------------------------------------------------------------------------
FROM nginx:1.25-alpine

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built React app from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Create non-root user (nginx already uses nginx user)
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

# Expose HTTP port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
