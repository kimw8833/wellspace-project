// routes/auth.routes.js

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

router.post('/api/register', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ ok: false, error: 'username and password are required' });
  }

  try {
    // 1) create user
    const [result] = await pool.query(
      'INSERT INTO users (username, password) VALUES (?, ?)',
      [username, password] // plain text
    );

    const newUserId = result.insertId;

    // 2) create room_status row (without any trigger in the database)
    await pool.query('INSERT INTO room_status (user_id) VALUES (?)', [newUserId]);

    return res.status(201).json({
      ok: true,
      user: { id: newUserId, username }
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, error: 'username already exists' });
    }
    console.error('DB error in /register:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// DELETE /api/users/:userId
router.delete('/api/users/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [result] = await pool.query(
      'DELETE FROM users WHERE id = ?',
      [userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        ok: false,
        error: 'User not found'
      });
    }

    return res.json({
      ok: true,
      message: `User ${userId} deleted`
    });
  } catch (err) {
    console.error('DB error in DELETE /api/users/:userId', err);
    return res.status(500).json({
      ok: false,
      error: 'Database error'
    });
  }
});


module.exports = router;