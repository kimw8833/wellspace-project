// routes/goals.routes.js

const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

// GET step_goal
router.get('/api/step-goal/:userId', async (req, res) => {
  const userId = req.params.userId;
  try {
    const [rows] = await pool.query(
      'SELECT step_goal FROM users WHERE id = ?',
      [userId]
    );
    if (rows.length === 0) return res.status(404).json({ ok: false, error: 'User not found' });
    return res.json({ ok: true, step_goal: rows[0].step_goal });
  } catch (err) {
    console.error('DB error in GET /step-goal:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// PUT step_goal
router.put('/api/step-goal/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { step_goal } = req.body;
  if (step_goal === undefined) return res.status(400).json({ ok: false, error: 'step_goal is required' });

  try {
    const [result] = await pool.query(
      'UPDATE users SET step_goal = ? WHERE id = ?',
      [step_goal, userId]
    );
    if (result.affectedRows === 0) return res.status(404).json({ ok: false, error: 'User not found' });
    return res.json({ ok: true, step_goal });
  } catch (err) {
    console.error('DB error in PUT /step-goal:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// GET waterintake_goal
router.get('/api/waterintake-goal/:userId', async (req, res) => {
  const userId = req.params.userId;
  try {
    const [rows] = await pool.query(
      'SELECT waterintake_goal FROM users WHERE id = ?',
      [userId]
    );
    if (rows.length === 0) return res.status(404).json({ ok: false, error: 'User not found' });
    return res.json({ ok: true, waterintake_goal: rows[0].waterintake_goal });
  } catch (err) {
    console.error('DB error in GET /waterintake-goal:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// PUT waterintake_goal
router.put('/api/waterintake-goal/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { waterintake_goal } = req.body;
  if (waterintake_goal === undefined) return res.status(400).json({ ok: false, error: 'waterintake_goal is required' });

  try {
    const [result] = await pool.query(
      'UPDATE users SET waterintake_goal = ? WHERE id = ?',
      [waterintake_goal, userId]
    );
    if (result.affectedRows === 0) return res.status(404).json({ ok: false, error: 'User not found' });
    return res.json({ ok: true, waterintake_goal });
  } catch (err) {
    console.error('DB error in PUT /waterintake-goal:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// GET user_location
router.get('/api/user-location/:userId', async (req, res) => {
  const userId = req.params.userId;
  try {
    const [rows] = await pool.query(
      'SELECT user_location FROM users WHERE id = ?',
      [userId]
    );
    if (rows.length === 0) return res.status(404).json({ ok: false, error: 'User not found' });
    return res.json({ ok: true, user_location: rows[0].user_location });
  } catch (err) {
    console.error('DB error in GET /user-location:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// PUT user_location
router.put('/api/user-location/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { user_location } = req.body;
  if (user_location === undefined) return res.status(400).json({ ok: false, error: 'user_location is required' });

  try {
    const [result] = await pool.query(
      'UPDATE users SET user_location = ? WHERE id = ?',
      [user_location, userId]
    );
    if (result.affectedRows === 0) return res.status(404).json({ ok: false, error: 'User not found' });
    return res.json({ ok: true, user_location });
  } catch (err) {
    console.error('DB error in PUT /user-location:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

module.exports = router;