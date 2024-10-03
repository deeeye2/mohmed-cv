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

# Install PyYAML separately if needed
RUN pip install PyYAML

# Install Nginx and create necessary directories
RUN apt-get update && apt-get install -y nginx \
    && mkdir -p /var/run/nginx /var/cache/nginx /var/log/nginx \
    && chown -R root:root /var/run/nginx \
    && chown -R root:root /var/cache/nginx \
    && chown -R root:root /var/log/nginx

# Copy the .env file into the container at /app
COPY .env /app/.env

# Expose ports 5000 (Python app) and 80 (Nginx)
EXPOSE 5000 80

# Run both Python app and Nginx server using a shell command
CMD /bin/bash -c "python app.py & nginx -g 'daemon off;'"
