# Stage 1: Optional Build Stage (Skip if not needed)
# Only include this stage if you have build steps, like `npm install` or `npm run build`.
# You can comment out or remove this stage if you are not building a frontend application.

# FROM node:16-alpine as builder
# Set working directory inside the container
# WORKDIR /app

# Copy the package.json and package-lock.json files for dependency installation
# COPY templates/package.json templates/package-lock.json ./

# Install dependencies
# RUN npm install

# Copy the frontend source files (HTML, CSS, JS, etc.) to the container
# COPY templates/ templates/
# COPY static/ static/
# COPY templates/index.html ./

# (Optional) If the frontend requires a build step, run it here
# RUN npm run build

# Stage 2: Nginx Stage to Serve Static Files
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy static files and templates directly to the Nginx HTML directory
COPY static/ static/
COPY templates/ templates/
COPY templates/index.html ./

# Copy a custom Nginx configuration file (if applicable)
# Uncomment the next line if you have a custom nginx.conf file
# COPY nginx.conf /etc/nginx/nginx.conf

# Create a non-root user and group for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership and permissions of necessary folders
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    mkdir -p /var/run/nginx && \
    chown -R appuser:appgroup /var/run/nginx

# Switch to the non-root user
USER appuser

# Expose the port Nginx will run on
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]


