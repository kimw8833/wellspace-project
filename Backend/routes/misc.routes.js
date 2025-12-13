const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

router.get('/api/ping', (req, res) => {
  res.json({ message: 'pong', time: new Date().toISOString() });
});

router.get('/api/test-db', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT NOW() AS now');
    res.json({ ok: true, nowFromDb: rows[0].now });
  } catch (err) {
    console.error('DB error in /test-db:', err);
    res.status(500).json({ ok: false, error: 'Database error' });
  }
});

router.get('/api/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, username FROM users');
    res.json(rows);
  } catch (err) {
    console.error('DB error in /users:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;