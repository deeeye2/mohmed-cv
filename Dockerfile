# Stage 1: Build stage
FROM python:3.8-slim as builder

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the source code
COPY . .

# Stage 2: Final stage
FROM python:3.8-slim

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=builder /app /app

# Copy the static files
COPY static /app/static

# Install PyYAML and Nginx separately if needed
RUN pip install PyYAML && apt-get update && apt-get install -y nginx \
    && mkdir -p /var/run/nginx /var/cache/nginx /var/log/nginx \
    && chown -R root:root /var/run/nginx /var/cache/nginx /var/log/nginx

# Copy the start script into the container
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Copy the .env file into the container at /app
COPY .env /app/.env

# Expose ports 5000 (Python app) and 80 (Nginx)
EXPOSE 5000 80

# Use the custom script as the entrypoint
ENTRYPOINT ["/start.sh"]

