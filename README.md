# ASCII Image Converter 

## Overview
This project is a simple web application that converts uploaded images into ASCII art. It is built using Flask and utilizes the Pillow and NumPy libraries to process images. The generated ASCII art is displayed on a web page and saved as a text file.


### `app.py`
```python

import os
import numpy as np
from flask import Flask, request, render_template
from PIL import Image, ImageEnhance
from datetime import datetime

app = Flask(__name__)

UPLOAD_FOLDER = "static/uploaded"
CONVERTED_FOLDER = "static/converted"

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CONVERTED_FOLDER, exist_ok=True)

ASCII_CHARS = "@#$%?*+;:,.!"  # Darker to lighter characters

def image_to_ascii(image_path, output_path, width=100, contrast_factor=1.5):
    img = Image.open(image_path)
    aspect_ratio = img.height / img.width

    # Multiply by 0.55 to correct distortion
    new_height = int(width * aspect_ratio * 0.55)
    
    img = img.resize((width, new_height))  # Assign resized image
    img = img.convert("L")  # Convert image to grayscale

    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(contrast_factor)

    pixels = np.array(img)
    normalized_pixels = (pixels / 255) * (len(ASCII_CHARS) - 1)
    
    ascii_str = "\n".join(
        "".join(ASCII_CHARS[int(pixel)] for pixel in row)
        for row in normalized_pixels.astype(int)  # Ensure integer indices
    )

    # Save the ASCII text file
    with open(output_path, "w") as f:
        f.write(ascii_str)

    return ascii_str

@app.route("/", methods=["GET", "POST"])
def home():
    if request.method == "POST":
        if "image" not in request.files:
            return "No file part", 400
        file = request.files["image"]

        if file.filename == "":
            return "No selected file", 400

        if file:
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
            filename = f"{timestamp}_{file.filename}"
            upload_path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(upload_path)
            print(f"File saved: {upload_path}")

            converted_filename = f"{filename}_ascii.txt"
            converted_path = os.path.join(CONVERTED_FOLDER, converted_filename)

            ascii_str = image_to_ascii(upload_path, converted_path)
            print(f"ASCII Art saved at: {converted_path}")

            print(f"Generated ASCII Preview:\n{ascii_str[:300]}")

            return render_template("index.html", ascii_str=ascii_str)

    return render_template("index.html")

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=5000)

```


### `templates/index.html`
```HTML

<!DOCTYPE html>
<html>
<head>
</head>
<body>
 <h1>Upload an image to convert to ascii</h1>
 <form action="/" method="post" enctype="multipart/form-data">    
<input type="file" name="image" required>
<button type="submit"> Upload </button>
</form>
    {% if ascii_str %}
    <h2>Generated ascii art</h2>
    <pre>{{ ascii_str }}</pre>
    {% endif %}
</body>
</html>


```

## Features
- Upload an image and convert it into ASCII art.
- Adjust contrast for better ASCII representation.
- Supports grayscale conversion and resizing.
- Simple web UI for easy interaction.
- Dockerized setup for easy deployment.

## Tech Stack
- Python (Flask, Pillow, NumPy)
- HTML (Jinja2 for templating)
- Docker (Containerization with Docker Compose)

## Step-by-Step Development Process
### 1. Creating the Flask Application (`app.py`)
- Initialized a Flask app with a simple route (`/`) to serve the web interface.
- Implemented an image upload system with `Flask.request.files` to handle user-submitted images.
- Created directories (`static/uploaded`, `static/converted`) to store images and ASCII outputs.
- Developed the `image_to_ascii` function to process images:
  - Resized images while maintaining aspect ratio.
  - Converted them to grayscale using Pillow.
  - Applied contrast enhancement.
  - Mapped pixel intensities to ASCII characters.
  - Generated a text file with ASCII representation.

### 2. Designing the Frontend (`index.html`)
- Built a minimal UI with a file upload form.
- Used Jinja2 templating to dynamically display the generated ASCII art.
- Styled the page with basic HTML elements to enhance readability.

### 3. Dockerizing the Application
- Created a `Dockerfile`:
  - Used `python:3.9-slim` as the base image.
  - Copied only necessary files to optimize image size.
  - Installed dependencies using `pip`.
  - Set up an entry point to run the Flask app.
- Defined a `docker-compose.yml`:
  - Configured a containerized Flask service.
  - Mapped ports for local access.
  - Attached a volume to persist uploaded images and generated ASCII files.
  - Created a custom network to isolate the service.

## Project Structure
```
📁 ascii-image-converter
│-- 📁 static
│   ├── 📁 uploaded (Stores uploaded images)
│   ├── 📁 converted (Stores generated ASCII text files)
│-- 📁 templates
│   ├── index.html (Frontend UI for file upload and ASCII display)
│-- app.py (Main Flask application)
│-- requirements.txt (Dependencies list)
│-- Dockerfile (Container setup for Flask app)
│-- docker-compose.yml (Multi-container setup)
│-- README.md (Project documentation)
```

## Installation & Usage
### 1. Clone the Repository
```sh
git clone https://github.com/Sayantan2k24/image_to_ascii_converter_webapp_docker.git
cd image_to_ascii_converter_webapp_docker
```

### 2. Build and Run with Docker Compose
```sh
docker-compose up -d
```
Access the application at `http://127.0.0.1:5000/`. (From inside the Docker Host)
Access the application at `http://<IP_Docker_Host>:5000/`. (From outside the Docker Host)

## Docker Configuration

### `Dockerfile`
```dockerfile
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
```

### `docker-compose.yml`
```yaml
version: "3.8"

services:
  flask_app:
    build: .
    container_name: "img_to_ascii"
    ports:
      - "5000:5000"
    volumes:
      - /images_ascii_db:/app/static
    environment:
      - FLASK_ENV=development
    networks:
      - ascii_custom_net  

networks:
  ascii_custom_net:
    name: ascii_image_network
    driver: bridge  
```




