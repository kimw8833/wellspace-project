// routes/achievements.routes.js
const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

// ---------------------------------------------------------
// GET achievements for a user
// Returns: [{ achievement_index: 1, progress: 30, claimed: 0/1, tier: 0 }, ...]
// done logic at frontend: progress >= 100
// ---------------------------------------------------------
router.get('/api/achievements/:userId', async (req, res) => {
  try {
    const userId = Number(req.params.userId);
    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid userId' });
    }

    const [rows] = await pool.query(
      `SELECT achievement_index, progress, claimed, tier
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
// body: { "progress": 0..100, "claimed"?: true/false/0/1, "tier"?: int }
// - progress is still REQUIRED.
// - claimed/tier optional: if not provided, keep old values
// ---------------------------------------------------------
router.put('/api/achievements/:userId/:index', async (req, res) => {
  try {
    const userId = Number(req.params.userId);
    const index = Number(req.params.index);
    const progress = Number(req.body?.progress);

    // (optional fields)
    const hasClaimed = req.body?.claimed !== undefined;
    const hasTier = req.body?.tier !== undefined;

    let claimedValue = null; // null => do not change
    let tierValue = null;    // null => do not change

    if (hasClaimed) {
      const c = req.body.claimed;
      if (c === true || c === 1 || c === '1') claimedValue = 1;
      else if (c === false || c === 0 || c === '0') claimedValue = 0;
      else return res.status(400).json({ success: false, message: 'claimed must be true/false or 0/1' });
    }

    if (hasTier) {
      const t = Number(req.body.tier);
      if (!Number.isInteger(t) || t < 0) {
        return res.status(400).json({ success: false, message: 'tier must be an int >= 0' });
      }
      tierValue = t;
    }

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
    // (in case no claimed/tier update only progress)
    if (!hasClaimed && !hasTier) {
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
    }

    // In case there are claimed/tier -> update with COALESCE
    // Use COALESCE to keep old values if provided values were null
    const [result2] = await pool.query(
      `UPDATE user_achievements
       SET progress = ?,
           claimed = COALESCE(?, claimed),
           tier    = COALESCE(?, tier)
       WHERE user_id = ? AND achievement_index = ?`,
      [p, claimedValue, tierValue, userId, index]
    );

    // 2) if no row, insert
    // If no claimed/tier provided, insert with defaults (claimed=0, tier=0)
    if (result2.affectedRows === 0) {
      if (!hasClaimed && !hasTier) {
        await pool.query(
          `INSERT INTO user_achievements (user_id, achievement_index, progress)
           VALUES (?, ?, ?)`,
          [userId, index, p]
        );
      } else {
        await pool.query(
          `INSERT INTO user_achievements (user_id, achievement_index, progress, claimed, tier)
           VALUES (?, ?, ?, COALESCE(?, 0), COALESCE(?, 0))`,
          [userId, index, p, claimedValue, tierValue]
        );
      }
    }

    return res.json({
      success: true,
      user_id: userId,
      achievement_index: index,
      progress: p,
      // Send back only the received input values for claimed/tier otherwise null
      claimed: claimedValue,
      tier: tierValue,
    });

  } catch (err) {
    console.error('PUT /achievements/:userId/:index error:', err);

    // in case of race condition insert again (rare) to get fallback update again
    if (err && err.code === 'ER_DUP_ENTRY') {
      try {
        const userId = Number(req.params.userId);
        const index = Number(req.params.index);
        const p = Math.round(Number(req.body?.progress));

        const hasClaimed = req.body?.claimed !== undefined;
        const hasTier = req.body?.tier !== undefined;

        let claimedValue = null;
        let tierValue = null;

        if (hasClaimed) {
          const c = req.body.claimed;
          claimedValue = (c === true || c === 1 || c === '1') ? 1
                      : (c === false || c === 0 || c === '0') ? 0
                      : null;
        }
        if (hasTier) {
          const t = Number(req.body.tier);
          if (Number.isInteger(t) && t >= 0) tierValue = t;
        }

        if (!hasClaimed && !hasTier) {
          await pool.query(
            `UPDATE user_achievements
             SET progress = ?
             WHERE user_id = ? AND achievement_index = ?`,
            [p, userId, index]
          );

          return res.json({ success: true, user_id: userId, achievement_index: index, progress: p });
        }

        await pool.query(
          `UPDATE user_achievements
           SET progress = ?,
               claimed = COALESCE(?, claimed),
               tier    = COALESCE(?, tier)
           WHERE user_id = ? AND achievement_index = ?`,
          [p, claimedValue, tierValue, userId, index]
        );

        return res.json({
          success: true,
          user_id: userId,
          achievement_index: index,
          progress: p,
          claimed: claimedValue,
          tier: tierValue,
        });

      } catch (err2) {
        console.error('DUP fallback update error:', err2);
      }
    }

    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
