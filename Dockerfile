# Stage 1: Build stage (Minimal configuration)
FROM python:3.8-slim as builder

# Set the working directory inside the container
WORKDIR /app

# Copy everything from the host to the container
COPY . .

# Stage 2: Serve frontend with Nginx
FROM nginx:alpine

# Set working directory inside Nginx container
WORKDIR /usr/share/nginx/html

# Copy all files from the builder stage to Nginx's serving directory
COPY --from=builder /app .

# Expose port 80 to access the application
EXPOSE 80

# Use Nginx to serve the frontend files
CMD ["nginx", "-g", "daemon off;"]
