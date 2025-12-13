const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

router.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ ok: false, error: 'username and password are required' });
  }

  try {
    const [rows] = await pool.query(
      'SELECT id, username FROM users WHERE username = ? AND password = ?',
      [username, password]
    );
    if (rows.length === 0) return res.status(401).json({ ok: false, error: 'Invalid username or password' });

    return res.json({ ok: true, user: rows[0] });
  } catch (err) {
    console.error('DB error in /login:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

module.exports = router;