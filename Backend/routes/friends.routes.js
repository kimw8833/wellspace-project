const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

// ------------------------------------------------------------
// FRIENDS API
// - Add friend: userId + friendUsername
// - Lists return id + username (frontend show username, actions use id)
// - Accept/remove: use ids
// ------------------------------------------------------------

// 1) send friend req. (by using friendUsername as input)
router.post('/api/friends/add', async (req, res) => {
  const { userId, friendUsername } = req.body;

  if (!userId || !friendUsername) {
    return res.status(400).json({
      ok: false,
      message: 'userId and friendUsername are required',
    });
  }

  try {
    // search friendId from username
    const [urows] = await pool.query(
      'SELECT id, username FROM users WHERE username = ?',
      [friendUsername]
    );

    if (urows.length === 0) {
      return res.status(404).json({ ok: false, message: 'User not found' });
    }

    const friendId = urows[0].id;

    if (friendId === userId) {
      return res.status(400).json({ ok: false, message: 'Cannot add yourself' });
    }

    // check: any existing relationship ? (from both side)
    const [existing] = await pool.query(
      `SELECT id, status, requester_id, receiver_id
       FROM friendships
       WHERE (requester_id = ? AND receiver_id = ?)
          OR (requester_id = ? AND receiver_id = ?)`,
      [userId, friendId, friendId, userId]
    );

    if (existing.length > 0) {
      const row = existing[0];

      if (row.status === 'accepted') {
        return res.json({ ok: true, message: 'Already friends' });
      }
      if (row.status === 'pending') {
        return res.json({ ok: true, message: 'Friend request already pending' });
      }

      return res.json({
        ok: true,
        message: `Existing relationship status: ${row.status}`,
      });
    }

    // Create a new friend request
    await pool.query(
      `INSERT INTO friendships (requester_id, receiver_id, status)
       VALUES (?, ?, 'pending')`,
      [userId, friendId]
    );

    return res.json({
      ok: true,
      message: 'Friend request sent',
      to: { id: friendId, username: friendUsername },
    });
  } catch (err) {
    console.error('POST /api/friends/add error:', err);
    return res.status(500).json({ ok: false, message: 'Server error' });
  }
});


// 2) Get a list of pending incoming requests
// Frotnend can use requester_username to show who requested
// Frontend can use requester_id to accept the request
router.get('/api/friend-requests/:userId', async (req, res) => {
  const userId = parseInt(req.params.userId, 10);

  if (!userId) {
    return res.status(400).json({ ok: false, message: 'Invalid userId' });
  }

  try {
    const [rows] = await pool.query(
      `SELECT
         f.id AS friendship_id,
         f.requester_id,
         u.username AS requester_username,
         f.created_at
       FROM friendships f
       JOIN users u ON u.id = f.requester_id
       WHERE f.receiver_id = ?
         AND f.status = 'pending'
       ORDER BY f.created_at DESC`,
      [userId]
    );

    return res.json({ ok: true, requests: rows });
  } catch (err) {
    console.error('GET /api/friend-requests/:userId error:', err);
    return res.status(500).json({ ok: false, message: 'Server error' });
  }
});


// 3) To accept friend req.
// Use ids only
// body: { userId, requesterId }
router.post('/api/friends/accept', async (req, res) => {
  const { userId, requesterId } = req.body;

  if (!userId || !requesterId) {
    return res.status(400).json({
      ok: false,
      message: 'userId and requesterId are required',
    });
  }

  try {
    const [result] = await pool.query(
      `UPDATE friendships
       SET status = 'accepted'
       WHERE requester_id = ?
         AND receiver_id  = ?
         AND status = 'pending'`,
      [requesterId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, message: 'No pending request found' });
    }

    return res.json({ ok: true, message: 'Friend request accepted' });
  } catch (err) {
    console.error('POST /api/friends/accept error:', err);
    return res.status(500).json({ ok: false, message: 'Server error' });
  }
});


// For reject button: To denine friend req.
// Use ids only
// body: { userId, requesterId }
router.post('/api/friends/reject', async (req, res) => {
  const { userId, requesterId } = req.body;

  if (!userId || !requesterId) {
    return res.status(400).json({
      ok: false,
      message: 'userId and requesterId are required',
    });
  }

  try {
    const [result] = await pool.query(
      `UPDATE friendships
       SET status = 'rejected'
       WHERE requester_id = ?
         AND receiver_id  = ?
         AND status = 'pending'`,
      [requesterId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, message: 'No pending request found' });
    }

    return res.json({ ok: true, message: 'Friend request rejected' });
  } catch (err) {
    console.error('POST /api/friends/reject error:', err);
    return res.status(500).json({ ok: false, message: 'Server error' });
  }
});


// 4) Get a list of friends
// All those frends with "accepted" status
// Frontend can show username, use id for actions
router.get('/api/friends/:userId', async (req, res) => {
  const userId = parseInt(req.params.userId, 10);

  if (!userId) {
    return res.status(400).json({ ok: false, message: 'Invalid userId' });
  }

  try {
    const [rows] = await pool.query(
      `SELECT
         u.id,
         u.username
       FROM friendships f
       JOIN users u ON (
            (f.requester_id = ? AND u.id = f.receiver_id)
         OR (f.receiver_id  = ? AND u.id = f.requester_id)
       )
       WHERE f.status = 'accepted'
       ORDER BY u.username ASC`,
      [userId, userId]
    );

    return res.json({ ok: true, friends: rows });
  } catch (err) {
    console.error('GET /api/friends/:userId error:', err);
    return res.status(500).json({ ok: false, message: 'Server error' });
  }
});


// 5) Unfriend by only using ids
// body: { userId, friendId }
router.delete('/api/friends', async (req, res) => {
  const { userId, friendId } = req.body;

  if (!userId || !friendId) {
    return res.status(400).json({
      ok: false,
      message: 'userId and friendId are required',
    });
  }

  try {
    const [result] = await pool.query(
      `DELETE FROM friendships
       WHERE status = 'accepted'
         AND (
              (requester_id = ? AND receiver_id = ?)
           OR (requester_id = ? AND receiver_id = ?)
         )`,
      [userId, friendId, friendId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, message: 'No friendship found' });
    }

    return res.json({ ok: true, message: 'Friend removed' });
  } catch (err) {
    console.error('DELETE /api/friends error:', err);
    return res.status(500).json({ ok: false, message: 'Server error' });
  }
});

module.exports = router;