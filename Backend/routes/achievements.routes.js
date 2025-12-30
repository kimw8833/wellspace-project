// routes/achievements.routes.js
const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

function parseUserId(req, res) {
  const userId = Number(req.params.userId);
  if (!Number.isInteger(userId) || userId <= 0) {
    res.status(400).json({ success: false, message: 'Invalid userId' });
    return null;
  }
  return userId;
}

function parseIndex(req, res) {
  const index = Number(req.params.index);
  if (!Number.isInteger(index) || index <= 0) {
    res.status(400).json({ success: false, message: 'Invalid achievement index' });
    return null;
  }
  return index;
}

// ---------------------------------------------------------
// GET achievements
// ---------------------------------------------------------
router.get('/api/achievements/:userId', async (req, res) => {
  try {
    const userId = parseUserId(req, res);
    if (!userId) return;

    const [rows] = await pool.query(
      `SELECT achievement_index, progress, claimed, tier
       FROM user_achievements
       WHERE user_id = ?
       ORDER BY achievement_index ASC`,
      [userId]
    );

    return res.json({ success: true, achievements: rows });
  } catch (err) {
    console.error('GET /api/achievements/:userId error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ---------------------------------------------------------
// PUT progress only (UPSERT)
// PUT /api/achievements/:userId/:index/progress
// body: { progress: 0..100 }
// ---------------------------------------------------------
router.put('/api/achievements/:userId/:index/progress', async (req, res) => {
  try {
    const userId = parseUserId(req, res);
    const index = parseIndex(req, res);
    if (!userId || !index) return;

    const progress = Number(req.body?.progress);
    if (!Number.isFinite(progress) || progress < 0 || progress > 100) {
      return res.status(400).json({ success: false, message: 'progress must be 0..100' });
    }
    const p = Math.round(progress);

    await pool.query(
      `INSERT INTO user_achievements (user_id, achievement_index, progress)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE progress = VALUES(progress)`,
      [userId, index, p]
    );

    return res.json({ success: true, user_id: userId, achievement_index: index, progress: p });
  } catch (err) {
    console.error('PUT /progress error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ---------------------------------------------------------
// PUT claimed only (UPSERT)
// PUT /api/achievements/:userId/:index/claimed
// body: { claimed: 0/1 (or true/false) }
// ---------------------------------------------------------
router.put('/api/achievements/:userId/:index/claimed', async (req, res) => {
  try {
    const userId = parseUserId(req, res);
    const index = parseIndex(req, res);
    if (!userId || !index) return;

    const c = req.body?.claimed;
    let claimed = null;
    if (c === true || c === 1 || c === '1') claimed = 1;
    else if (c === false || c === 0 || c === '0') claimed = 0;

    if (claimed === null) {
      return res.status(400).json({ success: false, message: 'claimed must be true/false or 0/1' });
    }

    // If row doesn't exist yet, insert with default progress=0, tier=0
    await pool.query(
      `INSERT INTO user_achievements (user_id, achievement_index, progress, claimed, tier)
       VALUES (?, ?, 0, ?, 0)
       ON DUPLICATE KEY UPDATE claimed = VALUES(claimed)`,
      [userId, index, claimed]
    );

    return res.json({ success: true, user_id: userId, achievement_index: index, claimed });
  } catch (err) {
    console.error('PUT /claimed error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ---------------------------------------------------------
// PUT tier only (UPSERT)
// PUT /api/achievements/:userId/:index/tier
// body: { tier: int >= 0 }
// ---------------------------------------------------------
router.put('/api/achievements/:userId/:index/tier', async (req, res) => {
  try {
    const userId = parseUserId(req, res);
    const index = parseIndex(req, res);
    if (!userId || !index) return;

    const t = Number(req.body?.tier);
    if (!Number.isInteger(t) || t < 0) {
      return res.status(400).json({ success: false, message: 'tier must be an int >= 0' });
    }

    // If row doesn't exist yet, insert with default progress=0, claimed=0
    await pool.query(
      `INSERT INTO user_achievements (user_id, achievement_index, progress, claimed, tier)
       VALUES (?, ?, 0, 0, ?)
       ON DUPLICATE KEY UPDATE tier = VALUES(tier)`,
      [userId, index, t]
    );

    return res.json({ success: true, user_id: userId, achievement_index: index, tier: t });
  } catch (err) {
    console.error('PUT /tier error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
