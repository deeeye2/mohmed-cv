# Use the official Python image from the Docker Hub
FROM python:3.8-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Copy the manifest generator HTML, JS, and CSS files
COPY file_generator.html /app/templates/
COPY script.js /app/static/
COPY styles.css /app/static/

# Install any needed packages specified in requirements.txt
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Copy the .env file into the container at /app
COPY .env /app/.env

# Run app.py when the container launches
CMD ["python", "app.py"]

