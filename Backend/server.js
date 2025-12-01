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
// Route: Dog Status
//
// Get dog status for a specific user
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

    res.json({
      ok: true,
      dog_status: rows[0].dog_status  // skicka tillbaka dog status 0,1,2
    });
  } catch (err) {
    console.error('DB error:', err);
    res.status(500).json({ ok: false, error: 'Database error' });
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