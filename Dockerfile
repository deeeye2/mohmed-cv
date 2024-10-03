# Use the Python base image
FROM python:3.8-slim

# Set environment variables
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
ENV GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION=3.8.19
ENV PYTHON_PIP_VERSION=23.0.1
ENV PYTHON_SETUPTOOLS_VERSION=57.5.0
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/e03e1607ad60522cf34a92e834138eb89f57667c/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256=ee09098395e42eb1f82ef4acb231a767a6ae85504a9cf9983223df0a7cbd35d7

# Install necessary packages and Python
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev

# Set working directory
WORKDIR /app

# Copy necessary files
COPY /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY /app /app
COPY static /app/static
COPY .env /app/.env

# Install Python dependencies
RUN pip install -r /app/requirements.txt

# Expose the application port
EXPOSE 5000

# Final command to run the application
CMD ["python", "app.py"]
