#!/bin/bash
# Start the Python app in the background
python /app/app.py &
# Start Nginx in the foreground
nginx -g "daemon off;"
