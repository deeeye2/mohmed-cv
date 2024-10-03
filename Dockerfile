# Stage 1: Build Stage (if applicable)
FROM node:16-alpine as builder
WORKDIR /app

# Copy all necessary files for frontend build
COPY . .

# Stage 2: Nginx Stage
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy static files from the build stage (if applicable)
COPY static/ static/
COPY templates/ templates/
COPY index.html ./

# Copy the Nginx configuration file from host to container
# If you want to use a custom configuration file, include it in the Docker context and copy it
COPY /etc/nginx/sites-available/default /etc/nginx/conf.d/default.conf

# Set permissions for Nginx to access these files
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port 80 (HTTP)
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
