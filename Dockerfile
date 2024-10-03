# Stage 1: Build Stage (If you have a build step like npm build)
# Skip this stage if you're not using a frontend build tool like npm, yarn, etc.
FROM node:16-alpine as builder

# Set the working directory inside the container
WORKDIR /app

# If you have a build step, you would copy your source files here
# Uncomment the following lines if you have package.json and package-lock.json files
# COPY templates/package.json templates/package-lock.json ./

# Install dependencies (Uncomment if applicable)
# RUN npm install

# Copy all necessary frontend source files to the container (HTML, CSS, JS, etc.)
COPY templates/ templates/
COPY static/ static/
COPY templates/index.html ./

# If your frontend requires a build step (e.g., React or Vue.js), run it here
# Uncomment if applicable
# RUN npm run build

# Stage 2: Nginx Stage to Serve Static Frontend Files
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy static files and templates from the build stage to Nginx
COPY static/ static/
COPY templates/ templates/
COPY templates/index.html ./

# Create a non-root user and group for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership and permissions of necessary directories
# Adjust Nginx configuration to use a custom PID file location and permissions
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    mkdir -p /var/run/nginx && \
    chown -R appuser:appgroup /var/run/nginx

# Copy a custom Nginx configuration file to use /var/tmp/nginx.pid
# This is needed to avoid permission issues with the default /var/run/nginx.pid location
COPY nginx.conf /etc/nginx/nginx.conf

# Switch to non-root user for security
USER appuser

# Expose port 80 to access the application
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

