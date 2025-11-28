// server.js
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 3000; // kan ändra

// tillåter backend läsa JSON body samt Flutter/web calls över the origin
app.use(cors());
app.use(express.json());

// create MySQL connection pool
const pool = mysql.createPool({
  host: 'localhost',
  user: 'wellspace',
  password: 'wellspace2025',
  database: 'wellspacedb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// ------------------- routes -------------------


// Test login route
// Flutter or client send JSON: { "username": "Kim", "password": "1234" }
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

/*

Flutter eller klient skickar JSON:
{ "username": "Kim", "password": "1234" }

Om det gick bra, svara med JSON:
{
  "ok": true,
  "user": {
    "id": 1,
    "username": "Kim"
  }
}
Om det gick dåligt, svara med JSON:
{
  "ok": false,
  "error": "Invalid username or password"
}

*/


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