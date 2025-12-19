// routes/achievements.routes.js
const express = require('express');
const router = express.Router();
const pool = require('../db/pool'); // ปรับ path ให้ตรงโปรเจกต์คุณ

// ---------------------------------------------------------
// GET achievements for a user
// Returns: [{ achievement_index: 1, progress: 30 }, ...]
// done logic at frontend: progress >= 100
// ---------------------------------------------------------
router.get('/api/achievements/:userId', async (req, res) => {
  try {
    const userId = Number(req.params.userId);
    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid userId' });
    }

    const [rows] = await pool.query(
      `SELECT achievement_index, progress
       FROM user_achievements
       WHERE user_id = ?
       ORDER BY achievement_index ASC`,
      [userId]
    );

    return res.json({ success: true, achievements: rows });
  } catch (err) {
    console.error('GET /achievements/:userId error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ---------------------------------------------------------
// UPDATE achievement progress (upsert)
// PUT /api/achievements/:userId/:index
// body: { "progress": 0..100 }
// ---------------------------------------------------------
router.put('/api/achievements/:userId/:index', async (req, res) => {
  try {
    const userId = Number(req.params.userId);
    const index = Number(req.params.index);
    const progress = Number(req.body?.progress);

    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid userId' });
    }
    if (!Number.isInteger(index) || index <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid achievement index' });
    }
    if (!Number.isFinite(progress) || progress < 0 || progress > 100) {
      return res.status(400).json({ success: false, message: 'progress must be 0..100' });
    }

    const p = Math.round(progress);

    // 1) try update first
    const [result] = await pool.query(
      `UPDATE user_achievements
       SET progress = ?
       WHERE user_id = ? AND achievement_index = ?`,
      [p, userId, index]
    );

    // 2) if no row, insert (works even if you didn't seed)
    if (result.affectedRows === 0) {
      await pool.query(
        `INSERT INTO user_achievements (user_id, achievement_index, progress)
         VALUES (?, ?, ?)`,
        [userId, index, p]
      );
    }

    return res.json({ success: true, user_id: userId, achievement_index: index, progress: p });
  } catch (err) {
    console.error('PUT /achievements/:userId/:index error:', err);

    // in case of race condition insert again (rare) to get fallback update again
    if (err && err.code === 'ER_DUP_ENTRY') {
      try {
        const userId = Number(req.params.userId);
        const index = Number(req.params.index);
        const p = Math.round(Number(req.body?.progress));

        await pool.query(
          `UPDATE user_achievements
           SET progress = ?
           WHERE user_id = ? AND achievement_index = ?`,
          [p, userId, index]
        );

        return res.json({ success: true, user_id: userId, achievement_index: index, progress: p });
      } catch (err2) {
        console.error('DUP fallback update error:', err2);
      }
    }

    return res.status(500).json({ success: false, message: 'Server error' });
  }
});


module.exports = router;
