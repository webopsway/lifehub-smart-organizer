# Build stage
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage with nginx
FROM nginx:alpine

# Install openssl for SSL generation
RUN apk add --no-cache openssl

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy built application
COPY --from=build /app/dist /var/www/html

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copy SSL certificates (will be mounted as volume)
VOLUME ["/etc/nginx/ssl"]

# Create nginx user for proper permissions
RUN addgroup -g 1001 -S nginx && \
    adduser -S -D -H -u 1001 -h /var/www/html -s /sbin/nologin -G nginx -g nginx nginx

# Create log directory
RUN mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/nginx-health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 