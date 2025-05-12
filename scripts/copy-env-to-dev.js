const fs = require('fs');
const path = require('path');

// Get all service directories
const servicesDir = path.join(__dirname, '../services');
const services = fs.readdirSync(servicesDir)
  .filter(dir => fs.statSync(path.join(servicesDir, dir)).isDirectory());

// Copy .env to .env.dev for each service, or create empty .env.dev if no .env exists
services.forEach(service => {
  const servicePath = path.join(servicesDir, service);
  const envPath = path.join(servicePath, '.env');
  const envDevPath = path.join(servicePath, '.env.dev');

  // Check if .env exists
  if (fs.existsSync(envPath)) {
    // Read .env content and write to .env.dev
    const envContent = fs.readFileSync(envPath, 'utf8');
    fs.writeFileSync(envDevPath, envContent);
    console.log(`Copied .env to .env.dev for ${service}`);
  } else {
    // Create empty .env.dev if no .env exists
    fs.writeFileSync(envDevPath, '');
    console.log(`Created empty .env.dev for ${service}`);
  }
});
