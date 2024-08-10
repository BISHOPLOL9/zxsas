#!/bin/bash

# Ensure we're in the correct directory
cd image-generator-webapp

# Update the HTML file with an improved UI, model selector, and safety toggle
cat > public/index.html << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Advanced AI Image Generator</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Advanced AI Image Generator</h1>
        <form id="image-form">
            <div class="form-group">
                <label for="prompt">Image Prompt:</label>
                <textarea id="prompt" name="prompt" required></textarea>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="model">Model:</label>
                    <select id="model" name="model">
                        <option value="fal-ai/flux-pro">Flux Pro</option>
                        <option value="fal-ai/flux/dev">Flux Dev</option>
                        <option value="fal-ai/flux-realism">Flux Realism</option>
                        <option value="fal-ai/flux/schnell">Flux Schnell</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="image_size">Image Size:</label>
                    <select id="image_size" name="image_size">
                        <option value="landscape_4_3">Landscape 4:3</option>
                        <option value="square_hd">Square HD</option>
                        <option value="square">Square</option>
                        <option value="portrait_4_3">Portrait 4:3</option>
                        <option value="portrait_16_9">Portrait 16:9</option>
                        <option value="landscape_16_9">Landscape 16:9</option>
                    </select>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="num_inference_steps">Inference Steps:</label>
                    <input type="number" id="num_inference_steps" name="num_inference_steps" value="28" min="1" max="100">
                </div>
                
                <div class="form-group">
                    <label for="seed">Seed (optional):</label>
                    <input type="number" id="seed" name="seed">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="guidance_scale">Guidance Scale:</label>
                    <input type="number" id="guidance_scale" name="guidance_scale" value="3.5" step="0.1" min="0" max="20">
                </div>
                
                <div class="form-group">
                    <label for="num_images">Number of Images:</label>
                    <input type="number" id="num_images" name="num_images" value="1" min="1" max="4">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group checkbox-group">
                    <input type="checkbox" id="enable_safety_checker" name="enable_safety_checker" checked>
                    <label for="enable_safety_checker">Enable Safety Checker</label>
                </div>
                
                <div class="form-group" id="safety_tolerance_group">
                    <label for="safety_tolerance">Safety Tolerance:</label>
                    <select id="safety_tolerance" name="safety_tolerance">
                        <option value="1">1 (Strictest)</option>
                        <option value="2" selected>2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6 (Most Permissive)</option>
                    </select>
                </div>
            </div>
            
            <button type="submit">Generate Image</button>
        </form>
        <div id="result"></div>
    </div>
    <script src="script.js"></script>
</body>
</html>
EOL

# Continuing the CSS file
cat >> public/styles.css << EOL
@media (max-width: 768px) {
    .container {
        padding: 1rem;
    }

    .form-row {
        flex-direction: column;
        gap: 1rem;
    }
}

.tooltip {
    position: relative;
    display: inline-block;
    cursor: help;
}

.tooltip .tooltiptext {
    visibility: hidden;
    width: 200px;
    background-color: #555;
    color: #fff;
    text-align: center;
    border-radius: 6px;
    padding: 5px;
    position: absolute;
    z-index: 1;
    bottom: 125%;
    left: 50%;
    margin-left: -100px;
    opacity: 0;
    transition: opacity 0.3s;
}

.tooltip:hover .tooltiptext {
    visibility: visible;
    opacity: 1;
}
EOL

# Update the JavaScript file to improve user experience and handle new features
cat > public/script.js << EOL
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('image-form');
    const resultDiv = document.getElementById('result');
    const safetyCheckerToggle = document.getElementById('enable_safety_checker');
    const safetyToleranceGroup = document.getElementById('safety_tolerance_group');

    safetyCheckerToggle.addEventListener('change', () => {
        safetyToleranceGroup.style.display = safetyCheckerToggle.checked ? 'block' : 'none';
    });

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());
        
        // Convert numeric fields
        data.num_inference_steps = parseInt(data.num_inference_steps);
        data.seed = data.seed ? parseInt(data.seed) : undefined;
        data.guidance_scale = parseFloat(data.guidance_scale);
        data.num_images = parseInt(data.num_images);
        data.enable_safety_checker = data.enable_safety_checker === 'on';
        
        resultDiv.innerHTML = '<p class="loading">Generating image(s)... Please wait.</p>';
        
        try {
            const response = await fetch('/generate-image', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data),
            });
            
            if (!response.ok) {
                throw new Error('Failed to generate image');
            }
            
            const result = await response.json();
            
            let resultHtml = '<h2>Generated Images:</h2>';
            result.images.forEach((image, index) => {
                resultHtml += \`<img src="\${image.url}" alt="Generated Image \${index + 1}" loading="lazy"><br>\`;
            });
            resultHtml += \`<p>Seed used: \${result.seed}</p>\`;
            if (data.enable_safety_checker) {
                resultHtml += \`<p>NSFW content detected: \${result.has_nsfw_concepts.join(', ')}</p>\`;
            }
            
            resultDiv.innerHTML = resultHtml;
        } catch (error) {
            console.error('Error:', error);
            resultDiv.innerHTML = '<p class="error">Error generating image. Please try again.</p>';
        }
    });
});
EOL

# Update the server file to handle new features
cat > server.js << EOL
require('dotenv').config();
const express = require('express');
const fal = require('@fal-ai/serverless-client');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

// Configure the API client
fal.config({
  credentials: process.env.FAL_KEY
});

app.use(express.json());
app.use(express.static('public'));

app.post('/generate-image', async (req, res) => {
  try {
    const { model, enable_safety_checker, ...input } = req.body;
    
    const result = await fal.subscribe(model, {
      input: {
        ...input,
        enable_safety_checker,
      },
      logs: true,
    });
    res.json(result);
  } catch (error) {
    console.error("Error generating image:", error);
    res.status(500).json({ error: "Failed to generate image" });
  }
});

app.listen(port, () => {
  console.log(\`Server running at http://localhost:\${port}\`);
});
EOL

# Update the .env file to use a higher port number
sed -i 's/PORT=3000/PORT=8080/' .env

echo "Advanced AI Image Generator Web App has been updated!"
echo "New features added:"
echo "- Model selection dropdown"
echo "- Safety checker toggle"
echo "- Improved UI and responsiveness"
echo "To start the server, run: node server.js"
echo "Then open http://localhost:8080 in your web browser."