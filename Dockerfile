# Stage 1: Nginx Stage
FROM nginx:alpine

# Set the working directory inside Nginx
WORKDIR /usr/share/nginx/html

# Copy all frontend files (HTML, CSS, JS, etc.) to the Nginx container
COPY . .

# Expose port 80 to access the application
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
