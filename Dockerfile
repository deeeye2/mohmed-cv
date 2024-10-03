# Stage 1: Build stage
FROM node:16-alpine as builder

# Create and set working directory
WORKDIR /app

# Copy only the necessary files to install dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the source files (HTML, CSS, JS, etc.)
COPY static/ static/
COPY templates/ templates/
COPY index.html ./

# If you have a build script for your frontend, run it here (e.g., npm run build)
# RUN npm run build

# Stage 2: Final stage - Serve with Nginx
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy built frontend files from the builder stage
COPY --from=builder /app .

# Create a non-root user and group for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change permissions for nginx folder and configuration
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx

# Switch to non-root user
USER appuser

# Expose port 80 to access the application
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

