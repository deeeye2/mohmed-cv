# Stage 1: Build stage
FROM node:16-alpine as builder

# Create and set working directory
WORKDIR /app

# Copy only the necessary files to install dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the source files (e.g., HTML, CSS, JS)
COPY . .

# Build the frontend assets (e.g., if using React, Vue, or Angular)
RUN npm run build

# Stage 2: Final stage (serve-only image)
FROM nginx:alpine

# Set the working directory
WORKDIR /usr/share/nginx/html

# Copy built files from the builder stage
COPY --from=builder /app/build .

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
