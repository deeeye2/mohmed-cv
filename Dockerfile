# Stage 1: Build Stage (Only needed if you have a build step like npm build)
# Skip this stage if you're not using a frontend build tool like npm, yarn, etc.
FROM node:16-alpine as builder

# Set the working directory inside the container
WORKDIR /app

# (Optional) If you have a build step, you would copy your source files here
# COPY templates/package.json templates/package-lock.json ./

# (Optional) Install dependencies if you have package.json files
# RUN npm install

# Copy all necessary frontend source files to the container (HTML, CSS, JS, etc.)
COPY templates/ templates/
COPY static/ static/
COPY templates/index.html ./

# (Optional) If your frontend requires a build step (e.g., React or Vue.js), run it here
# RUN npm run build

# Stage 2: Nginx Stage
# Use the nginx:alpine image to serve the static frontend files
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy only the build output or source files from the builder stage to Nginx
# If you skipped the builder stage, use the paths directly from your local directory
COPY static/ static/
COPY templates/ templates/
COPY templates/index.html ./

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
