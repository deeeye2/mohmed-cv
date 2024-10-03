# Stage 1: Build Stage (Only needed if you have a build step like npm build)
# Skip this stage if you're not using a frontend build tool like npm, yarn, etc.
FROM node:16-alpine as builder

# Set the working directory inside the container
WORKDIR /app

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

# Copy only the frontend files directly to Nginx's HTML directory
COPY static/ static/
COPY templates/ templates/
COPY templates/index.html ./

# (Optional) If you have a custom nginx.conf file, copy it here
# COPY nginx.conf /etc/nginx/nginx.conf

# Allow nginx to write the PID file by setting proper permissions
RUN mkdir -p /var/run/nginx && \
    chown -R root:root /var/run/nginx && \
    chown -R root:root /var/cache/nginx && \
    chown -R root:root /var/log/nginx

# Expose port 80 to access the application
EXPOSE 80

# Start Nginx server as root user
CMD ["nginx", "-g", "daemon off;"]
