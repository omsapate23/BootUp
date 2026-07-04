const express = require('express');
const mongoose = require('mongoose');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/bootup_dev';

app.use(express.json());

// Main entry route
app.get('/', async (req, res) => {
  try {
    const isConnected = mongoose.connection.readyState === 1;
    const dbClass = isConnected ? 'connected' : 'disconnected';
    const dbText = isConnected ? 'MongoDB Sandbox Engine Online' : 'Database Synchronization Pending';
    
    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BootUp Developer Sandbox v1.0</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-color: #080c18;
      --card-bg: rgba(13, 20, 38, 0.75);
      --border-color: rgba(0, 114, 255, 0.15);
      --text-primary: #f8fafc;
      --text-secondary: #94a3b8;
      --azure-glow: rgba(0, 114, 255, 0.4);
      --azure-primary: #0072ff;
      --azure-secondary: #00c6ff;
    }
    
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-color);
      color: var(--text-primary);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      position: relative;
      overflow-x: hidden;
      padding: 2rem 1rem;
    }
    
    /* Background gradients */
    body::before {
      content: "";
      position: absolute;
      width: 400px;
      height: 400px;
      background: radial-gradient(circle, var(--azure-glow) 0%, transparent 70%);
      top: -100px;
      left: -100px;
      z-index: -1;
      filter: blur(50px);
    }
    
    body::after {
      content: "";
      position: absolute;
      width: 500px;
      height: 500px;
      background: radial-gradient(circle, rgba(0, 198, 255, 0.2) 0%, transparent 75%);
      bottom: -150px;
      right: -100px;
      z-index: -1;
      filter: blur(60px);
    }

    .container {
      width: 100%;
      max-width: 800px;
      z-index: 1;
    }

    /* Card styling */
    .card {
      background: var(--card-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid var(--border-color);
      border-radius: 24px;
      padding: 3rem;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.35), 
                  inset 0 1px 0 rgba(255, 255, 255, 0.1);
      display: flex;
      flex-direction: column;
      gap: 2rem;
      transition: all 0.3s ease;
    }

    .card:hover {
      border-color: rgba(0, 198, 255, 0.3);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 
                  0 0 30px rgba(0, 114, 255, 0.1),
                  inset 0 1px 0 rgba(255, 255, 255, 0.15);
    }

    /* Header */
    .header {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }

    .brand-title {
      font-family: 'Outfit', sans-serif;
      font-size: 2.25rem;
      font-weight: 700;
      letter-spacing: -0.5px;
      background: linear-gradient(135deg, var(--text-primary) 30%, #a5b4fc 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .brand-subtitle {
      font-size: 1.1rem;
      color: var(--text-secondary);
      font-weight: 500;
    }

    /* Status Pill */
    .status-container {
      display: flex;
      align-items: center;
    }

    .status-pill {
      display: inline-flex;
      align-items: center;
      gap: 0.6rem;
      padding: 0.6rem 1.25rem;
      border-radius: 9999px;
      font-size: 0.875rem;
      font-weight: 600;
      letter-spacing: 0.2px;
      transition: all 0.3s ease;
    }

    .status-pill.connected {
      background: rgba(0, 198, 255, 0.1);
      border: 1px solid rgba(0, 198, 255, 0.3);
      color: #00c6ff;
      box-shadow: 0 0 15px rgba(0, 198, 255, 0.15);
    }

    .status-pill.disconnected {
      background: rgba(148, 163, 184, 0.1);
      border: 1px solid rgba(148, 163, 184, 0.3);
      color: #94a3b8;
    }

    .pulse-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
    }

    .status-pill.connected .pulse-dot {
      background-color: #00c6ff;
      box-shadow: 0 0 8px #00c6ff;
      animation: pulse 1.8s infinite;
    }

    .status-pill.disconnected .pulse-dot {
      background-color: #94a3b8;
    }

    @keyframes pulse {
      0% {
        transform: scale(0.95);
        opacity: 0.6;
      }
      50% {
        transform: scale(1.2);
        opacity: 1;
        box-shadow: 0 0 12px #00c6ff;
      }
      100% {
        transform: scale(0.95);
        opacity: 0.6;
      }
    }

    /* Main Box */
    .workspace-box {
      background: rgba(8, 12, 24, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 16px;
      padding: 2rem;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    .welcome-text {
      font-size: 1.1rem;
      color: #cbd5e1;
      line-height: 1.6;
    }

    .instructions-list {
      list-style-type: none;
      display: flex;
      flex-direction: column;
      gap: 1.25rem;
    }

    .instruction-step {
      display: flex;
      gap: 1rem;
      align-items: flex-start;
      font-size: 0.95rem;
      color: var(--text-secondary);
      line-height: 1.5;
    }

    .step-number {
      background: linear-gradient(135deg, var(--azure-primary), var(--azure-secondary));
      color: white;
      width: 24px;
      height: 24px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 0.75rem;
      flex-shrink: 0;
      box-shadow: 0 2px 6px rgba(0, 114, 255, 0.3);
    }

    .code-span {
      font-family: 'Courier New', Courier, monospace;
      background: rgba(255, 255, 255, 0.08);
      padding: 0.2rem 0.4rem;
      border-radius: 6px;
      color: #e2e8f0;
      font-size: 0.85rem;
      border: 1px solid rgba(255, 255, 255, 0.05);
    }

    /* Live Testing Panel */
    .testing-panel {
      border-top: 1px solid rgba(255, 255, 255, 0.08);
      padding-top: 1.5rem;
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .testing-title {
      font-family: 'Outfit', sans-serif;
      font-size: 1.2rem;
      font-weight: 600;
      color: var(--text-primary);
    }

    .btn-group {
      display: flex;
      gap: 1rem;
      flex-wrap: wrap;
    }

    .btn {
      background: linear-gradient(135deg, var(--azure-primary), var(--azure-secondary));
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 10px;
      font-weight: 600;
      font-size: 0.9rem;
      cursor: pointer;
      transition: all 0.2s ease;
      box-shadow: 0 4px 10px rgba(0, 114, 255, 0.2);
    }

    .btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 15px rgba(0, 114, 255, 0.35);
    }

    .btn:active {
      transform: translateY(0);
    }

    .btn-secondary {
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.1);
      color: var(--text-primary);
      box-shadow: none;
    }

    .btn-secondary:hover {
      background: rgba(255, 255, 255, 0.1);
      border-color: rgba(255, 255, 255, 0.2);
      transform: translateY(-2px);
    }

    /* API Log Console */
    .console-box {
      background: #040815;
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 12px;
      padding: 1.25rem;
      font-family: 'Courier New', Courier, monospace;
      font-size: 0.85rem;
      color: #38bdf8;
      max-height: 250px;
      overflow-y: auto;
      white-space: pre-wrap;
      box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.5);
    }

    .footer {
      margin-top: 2rem;
      text-align: center;
      font-size: 0.85rem;
      color: var(--text-secondary);
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header">
        <h1 class="brand-title">BootUp Developer Sandbox v1.0 Active</h1>
        <div class="brand-subtitle">Isolated Node.js + MongoDB Workspace</div>
      </div>

      <div class="status-container">
        <span class="status-pill ${dbClass}">
          <span class="pulse-dot"></span>
          ${dbText}
        </span>
      </div>

      <div class="workspace-box">
        <p class="welcome-text">
          Congratulations! Your isolated web development sandbox is active and healthy. 
          The local files on your computer are synchronized in real-time with the virtual container server.
        </p>
        
        <ul class="instructions-list">
          <li class="instruction-step">
            <span class="step-number">1</span>
            <div>
              Open the local directory <span class="code-span">bootup_core/project_code/</span> in your favorite code editor to begin writing code.
            </div>
          </li>
          <li class="instruction-step">
            <span class="step-number">2</span>
            <div>
              Edit the server file or build API endpoints. Every change you save will automatically hot-reload inside the sandbox.
            </div>
          </li>
          <li class="instruction-step">
            <span class="step-number">3</span>
            <div>
              Add HTML, CSS, or interactive JavaScript to serve pages, or use Node.js to link database tables to your web frontends!
            </div>
          </li>
        </ul>
      </div>

      <div class="testing-panel">
        <h3 class="testing-title">Interactive API Tester</h3>
        <p style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">
          Verify container database reads and writes. Click the buttons below to interact with the backend MongoDB database:
        </p>
        <div class="btn-group">
          <button class="btn" onclick="fetchItems()">Get Items (/items)</button>
          <button class="btn btn-secondary" onclick="addItem()">Add Sample Item (/items)</button>
        </div>
        <div class="console-box" id="console">Loading console logs...</div>
      </div>
    </div>

    <div class="footer">
      Powered by BootUp Core &bull; Secure Linux Container Network
    </div>
  </div>

  <script>
    const consoleBox = document.getElementById('console');
    
    function logToConsole(message) {
      consoleBox.innerText = message;
    }
    
    logToConsole('Console ready. Click "Get Items" or "Add Sample Item" to test database integration.');

    async function fetchItems() {
      logToConsole('Sending GET request to /items...');
      try {
        const response = await fetch('/items');
        const data = await response.json();
        logToConsole(JSON.stringify(data, null, 2));
      } catch (error) {
        logToConsole('Error fetching items: ' + error.message);
      }
    }

    async function addItem() {
      logToConsole('Sending POST request to /items...');
      try {
        const randomId = Math.floor(Math.random() * 10000);
        const response = await fetch('/items', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ name: 'Sandbox Item #' + randomId })
        });
        const data = await response.json();
        logToConsole('Successfully added item! Response:\\n' + JSON.stringify(data, null, 2));
      } catch (error) {
        logToConsole('Error adding item: ' + error.message);
      }
    }
  </script>
</body>
</html>`;
    res.send(html);
  } catch (err) {
    res.status(500).send(`<h1>Internal Server Error</h1><p>${err.message}</p>`);
  }
});

// Test mongoose model
const ItemSchema = new mongoose.Schema({
  name: String,
  createdAt: { type: Date, default: Date.now }
});
const Item = mongoose.model('Item', ItemSchema);

// Endpoint to fetch test items from MongoDB
app.get('/items', async (req, res) => {
  try {
    const items = await Item.find();
    res.json({ status: 'success', count: items.length, data: items });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// Endpoint to add a test item
app.post('/items', async (req, res) => {
  try {
    const newItem = new Item({ name: req.body.name || 'Sample Item' });
    await newItem.save();
    res.status(201).json({ status: 'success', data: newItem });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// Database Connection & Server Startup
console.log('Connecting to MongoDB...');
mongoose.connect(mongoUri)
  .then(() => {
    console.log('MongoDB successfully connected!');
    app.listen(port, () => {
      console.log(`Server is running internally on port ${port}`);
      console.log(`Access it on your host machine at http://localhost:${port}`);
    });
  })
  .catch(err => {
    console.error('Failed to connect to MongoDB:', err.message);
    process.exit(1);
  });
