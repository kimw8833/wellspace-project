// routes/coin.routes.js

const express = require('express');
const router = express.Router();
const pool = require('../db/pool');


// -------------------------------------------------
// GET user coin
// GET /api/users/:userId/coin
// -------------------------------------------------
router.get('/api/users/:userId/coin', async (req, res) => {
  const { userId } = req.params;

  try {
    const [rows] = await pool.query(
      'SELECT coin FROM users WHERE id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        ok: false,
        error: 'User not found'
      });
    }

    return res.json({
      ok: true,
      coin: rows[0].coin
    });
  } catch (err) {
    console.error('DB error in GET /coin:', err);
    return res.status(500).json({
      ok: false,
      error: 'Database error'
    });
  }
});


// -------------------------------------------------
// UPDATE user coin (set value)
// PUT /api/users/:userId/coin
// body: { coin: number }
// -------------------------------------------------
router.put('/api/users/:userId/coin', async (req, res) => {
  const { userId } = req.params;
  const { coin } = req.body;

  if (coin === undefined) {
    return res.status(400).json({
      ok: false,
      error: 'coin is required'
    });
  }

  try {
    const [result] = await pool.query(
      'UPDATE users SET coin = ? WHERE id = ?',
      [coin, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        ok: false,
        error: 'User not found'
      });
    }

    return res.json({
      ok: true,
      userId,
      coin
    });
  } catch (err) {
    console.error('DB error in PUT /coin:', err);
    return res.status(500).json({
      ok: false,
      error: 'Database error'
    });
  }
});

module.exports = router;
