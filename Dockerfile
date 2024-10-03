# Stage 1: Builder Stage
# Use a Node.js image to build the frontend assets
FROM node:16-alpine as builder

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json files to install dependencies (if applicable)
COPY templates/package.json templates/package-lock.json ./

# Install the dependencies
RUN npm install --production

# Copy all necessary frontend source files to the container (HTML, CSS, JS, etc.)
COPY templates/index.html ./
COPY static/ static/


# If your frontend requires a build step (e.g., React or Vue.js), run it here
# Replace 'npm run build' with your actual build command if applicable
RUN npm run build

# Stage 2: Nginx Stage
# Use the nginx:alpine image to serve the built frontend files
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy only the build output from the previous stage to Nginx
COPY --from=builder /app/build .  # Adjust the path if your build output directory is different

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
