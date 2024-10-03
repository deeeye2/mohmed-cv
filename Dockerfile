# Stage 1: Build stage
FROM --platform=linux/amd64 python:3.8-slim as builder

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the source code
COPY . .

# Stage 2: Final stage
FROM --platform=linux/amd64 python:3.8-slim

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=builder /app /app

# Copy the static files
COPY static /app/static

# Install PyYAML separately if needed
RUN pip install PyYAML

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Copy the .env file into the container at /app
COPY .env /app/.env

# Set the entrypoint to use the appropriate shell format
ENTRYPOINT ["python", "app.py"]



