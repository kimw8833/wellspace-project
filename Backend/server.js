// server.js
// Sets up an Express server
// Imports and setups the Express framework, which is used for handling HTTP requests and creating a web server.
const express = require('express');
const cors    = require('cors');

// Connects to a MySQL database using a connection pool.
// Imports the MySQL2 library, which allows the application to interact with a MySQL database.
const mysql = require('mysql2/promise');

// Create a MySQL connection pool
// A connection pool improves performance
// by keeping a set of database connections open and reusing them,
// instead of creating a new connection for each query.
const pool  = mysql.createPool({
  host: 'localhost',
  user: 'wellspace',
  password: 'wellspace2025',
  database: 'wellspacedb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Creates an instance of an Express application, which will be used to define routes and handle requests.
const app = express();
// Sets the port number that the server will listen on (port 3000 in this case).
const PORT = 3000; // kan ändra

// tillåter backend läsa JSON body samt Flutter/web calls över the origin
app.use(cors());
app.use(express.json());

//
// Routes
//
//

// GET plant_status, dog_status, window_status, room_mood
// ----------------------------------------------
// All will be queried from the table: room_status by the given user_id
//

// 1) Plant Status
app.get('/api/plant-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT plant_status FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      plant_status: rows[0].plant_status
    });

  } catch (err) {
    console.error('DB error (plant):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// 2) Dog Status
app.get('/api/dog-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT dog_status FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      dog_status: rows[0].dog_status
    });

  } catch (err) {
    console.error('DB error (dog):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// 3) Window Status
app.get('/api/window-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT window_status FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      window_status: rows[0].window_status
    });

  } catch (err) {
    console.error('DB error (window):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// 4) Room Mood
app.get('/api/room-mood/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT room_mood FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      room_mood: rows[0].room_mood
    });

  } catch (err) {
    console.error('DB error (room):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

//
// Update Routes
//

//
// Update plant_status, dog_status, window_status, room_mood
// in table room_status for a given user_id
//

// 1) Update Plant Status
// Client sends JSON: { "plant_status": 0.75 }
app.put('/api/plant-status/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { plant_status } = req.body;

  // simple check if value is provided
  if (plant_status === undefined) {
    return res.status(400).json({ ok: false, error: 'plant_status is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET plant_status = ?, 
          last_plant_update = NOW()
      WHERE user_id = ?
      `,
      [plant_status, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      plant_status: plant_status
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/plant-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});



// 2) Update Dog Status
// Client sends JSON: { "dog_status": 0.50 }
app.put('/api/dog-status/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { dog_status } = req.body;

  if (dog_status === undefined) {
    return res.status(400).json({ ok: false, error: 'dog_status is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET dog_status = ?, 
          last_dog_update = NOW()
      WHERE user_id = ?
      `,
      [dog_status, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      dog_status: dog_status
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/dog-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});



// 3) Update Window Status
// Client sends JSON: { "window_status": 1.00 }
app.put('/api/window-status/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { window_status } = req.body;

  if (window_status === undefined) {
    return res.status(400).json({ ok: false, error: 'window_status is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET window_status = ?, 
          last_room_update = NOW()
      WHERE user_id = ?
      `,
      [window_status, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      window_status: window_status
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/window-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});



// 4) Update Room Mood
// Client sends JSON: { "room_mood": 0.30 }
app.put('/api/room-mood/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { room_mood } = req.body;

  if (room_mood === undefined) {
    return res.status(400).json({ ok: false, error: 'room_mood is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET room_mood = ?, 
          last_room_update = NOW()
      WHERE user_id = ?
      `,
      [room_mood, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      room_mood: room_mood
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/room-mood:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// Get full room_status row for debugging (includes timestamps)
// Example: GET /api/room-status/1
app.get('/api/room-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      `SELECT user_id,
              plant_status,
              dog_status,
              window_status,
              room_mood,
              last_plant_update,
              last_dog_update,
              last_room_update,
              updated_at
       FROM room_status
       WHERE user_id = ?`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      room_status: rows[0],
    });
  } catch (err) {
    console.error('DB error in /api/room-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


//
// Route: Login
//
// Ex. Flutter or client send JSON: { "username": "Kim", "password": "1234" }
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  // Check required fields
  if (!username || !password) {
    return res.status(400).json({ ok: false, error: 'username and password are required' });
  }

  try {
    const [rows] = await pool.query(
      'SELECT id, username FROM users WHERE username = ? AND password = ?',
      [username, password]
    );

    if (rows.length === 0) {
      return res.status(401).json({ ok: false, error: 'Invalid username or password' });
    }

    // login successful
    res.json({
      ok: true,
      user: rows[0],
    });
  } catch (err) {
    console.error('DB error in /api/login:', err);
    res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// ------------------- For testing if server is running ------------------- 
// simple ping route
app.get('/api/ping', (req, res) => {
  res.json({ message: 'pong', time: new Date().toISOString() });
});

// check database connection
app.get('/api/test-db', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT NOW() AS now');
    res.json({ ok: true, nowFromDb: rows[0].now });
  } catch (err) {
    console.error('DB error in /api/test-db:', err);
    res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// Pull alla users from users table
// Send JSON array of users (no password)
app.get('/api/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, username FROM users');
    res.json(rows);
  } catch (err) {
    console.error('DB error in /api/users:', err);
    res.status(500).json({ error: 'Database error' });
  }
});


// ------------------------------------------------------

// Start to run server, run for life
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});