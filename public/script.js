document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('image-form');
    const resultDiv = document.getElementById('result');
    const saveContainer = document.getElementById('save-container');
    const saveButton = document.getElementById('save-image');
    const apiKeyInput = document.getElementById('api-key');

    // Load saved API key if exists
    const savedApiKey = localStorage.getItem('falApiKey');
    if (savedApiKey) {
        apiKeyInput.value = savedApiKey;
    }

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());
        
        // Save API key
        localStorage.setItem('falApiKey', data['api-key']);
        
        // Convert numeric fields
        data.num_inference_steps = parseInt(data.num_inference_steps);
        data.seed = data.seed ? parseInt(data.seed) : undefined;
        data.guidance_scale = parseFloat(data.guidance_scale);
        data.num_images = parseInt(data.num_images);
        
        resultDiv.innerHTML = '<p class="loading">Generating image(s)... Please wait.</p>';
        saveContainer.style.display = 'none';
        
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
                resultHtml += `<img src="${image.url}" alt="Generated Image ${index + 1}" loading="lazy"><br>`;
            });
            resultHtml += `<p>Seed used: ${result.seed}</p>`;
            
            resultDiv.innerHTML = resultHtml;
            saveContainer.style.display = 'block';
        } catch (error) {
            console.error('Error:', error);
            resultDiv.innerHTML = '<p class="error">Error generating image. Please try again.</p>';
        }
    });

    saveButton.addEventListener('click', () => {
        const images = resultDiv.querySelectorAll('img');
        images.forEach((img, index) => {
            const link = document.createElement('a');
            link.href = img.src;
            link.download = `generated-image-${index + 1}.jpg`;
            link.click();
        });
    });
});
