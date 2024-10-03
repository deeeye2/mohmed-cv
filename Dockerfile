# Stage 1: Build stage
FROM python:3.8-slim as builder

# Set working directory in the container
WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the source code into the container
COPY . .

# Stage 2: Final stage - Smaller image
FROM python:3.8-slim

# Set working directory
WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=builder /app /app

# Copy static files if needed
COPY static /app/static

# Install additional dependencies separately
RUN pip install PyYAML

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Copy the .env file for environment variables
COPY .env /app/.env

# Set the default command to run the application
CMD ["python", "app.py"]
