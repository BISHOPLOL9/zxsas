require('dotenv').config();
const express = require('express');
const fal = require('@fal-ai/serverless-client');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

app.use(express.json());
app.use(express.static('public'));

app.post('/generate-image', async (req, res) => {
  try {
    const { 'api-key': apiKey, ...input } = req.body;

    // Configure the API client with the provided key
    fal.config({
      credentials: apiKey
    });

    const result = await fal.subscribe("fal-ai/flux-pro", {
      input,
      logs: true,
    });
    res.json(result);
  } catch (error) {
    console.error("Error generating image:", error);
    res.status(500).json({ error: "Failed to generate image" });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
