# Use official Python image
FROM python:3.9-slim

# Set working directory in the container
WORKDIR /app

# Copy only necessary files
COPY app.py requirements.txt /app/
COPY templates /app/templates

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 5000

# Run the Flask app
CMD ["app.py"]
ENTRYPOINT ["python"]

