# Stage 1: Build Stage (Only needed if you have a build step like npm build)
# Skip this stage if you're not using a frontend build tool like npm, yarn, etc.
FROM node:16-alpine 

# Set the working directory inside the container
WORKDIR /app

# Copy all necessary frontend source files to the container (HTML, CSS, JS, etc.)
COPY . .


# (Optional) If your frontend requires a build step (e.g., React or Vue.js), run it here
# RUN npm run build


# Expose port 80 to access the application
EXPOSE 80

# Start Nginx server as root user
CMD ["nginx", "-g", "daemon off;"]
