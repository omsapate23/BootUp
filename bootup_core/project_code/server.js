const express = require('express');
const mongoose = require('mongoose');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/bootup_dev';

app.use(express.json());

// Main entry route
app.get('/', async (req, res) => {
  try {
    const dbStatus = mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected';
    res.json({
      status: 'success',
      message: 'Welcome to BootUp Node.js + MongoDB isolated development environment!',
      database: dbStatus,
      timestamp: new Date()
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
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
