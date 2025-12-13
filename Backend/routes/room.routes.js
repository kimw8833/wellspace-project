const express = require('express');
const router = express.Router();
const pool = require('../db/pool');



// GET plant_status, dog_status, window_status, room_mood
// ----------------------------------------------
// All will be queried from the table: room_status by the given user_id
//

// 1) Plant Status
router.get('/api/plant-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    // läsa plant_status
    const [rows] = await pool.query(
      'SELECT plant_status FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    // updatera tid vid hämtning (read timestamp)
    await pool.query(
      'UPDATE room_status SET last_plant_read = NOW() WHERE user_id = ?',
      [userId]
    );

    return res.json({
      ok: true,
      plant_status: rows[0].plant_status
    });

  } catch (err) {
    console.error('DB error (plant):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// 2) Dog Status
router.get('/api/dog-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT dog_status FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    await pool.query(
      'UPDATE room_status SET last_dog_read = NOW() WHERE user_id = ?',
      [userId]
    );

    return res.json({
      ok: true,
      dog_status: rows[0].dog_status
    });

  } catch (err) {
    console.error('DB error (dog):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// 3) Window Status
router.get('/api/window-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT window_status FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    await pool.query(
      'UPDATE room_status SET last_window_read = NOW() WHERE user_id = ?',
      [userId]
    );

    return res.json({
      ok: true,
      window_status: rows[0].window_status
    });

  } catch (err) {
    console.error('DB error (window):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});

// 4) Room Mood
router.get('/api/room-mood/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      'SELECT room_mood FROM room_status WHERE user_id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    await pool.query(
      'UPDATE room_status SET last_room_read = NOW() WHERE user_id = ?',
      [userId]
    );

    return res.json({
      ok: true,
      room_mood: rows[0].room_mood
    });

  } catch (err) {
    console.error('DB error (room):', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


//
// Update Routes
//

//
// Update plant_status, dog_status, window_status, room_mood
// in table room_status for a given user_id
//

// 1) Update Plant Status
// Client sends JSON: { "plant_status": 0.75 }
router.put('/api/plant-status/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { plant_status } = req.body;

  // simple check if value is provided
  if (plant_status === undefined) {
    return res.status(400).json({ ok: false, error: 'plant_status is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET plant_status = ?, 
          last_plant_update = NOW()
      WHERE user_id = ?
      `,
      [plant_status, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      plant_status: plant_status
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/plant-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});



// 2) Update Dog Status
// Client sends JSON: { "dog_status": 0.50 }
router.put('/api/dog-status/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { dog_status } = req.body;

  if (dog_status === undefined) {
    return res.status(400).json({ ok: false, error: 'dog_status is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET dog_status = ?, 
          last_dog_update = NOW()
      WHERE user_id = ?
      `,
      [dog_status, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      dog_status: dog_status
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/dog-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// 3) Update Window Status
// Client sends JSON: { "window_status": 1.00 }
router.put('/api/window-status/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { window_status } = req.body;

  if (window_status === undefined) {
    return res.status(400).json({ ok: false, error: 'window_status is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET window_status = ?, 
          last_window_update = NOW()
      WHERE user_id = ?
      `,
      [window_status, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      window_status: window_status
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/window-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// 4) Update Room Mood
// Client sends JSON: { "room_mood": 0.30 }
router.put('/api/room-mood/:userId', async (req, res) => {
  const userId = req.params.userId;
  const { room_mood } = req.body;

  if (room_mood === undefined) {
    return res.status(400).json({ ok: false, error: 'room_mood is required' });
  }

  try {
    const [result] = await pool.query(
      `
      UPDATE room_status
      SET room_mood = ?, 
          last_room_update = NOW()
      WHERE user_id = ?
      `,
      [room_mood, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      room_mood: room_mood
    });
  } catch (err) {
    console.error('DB error in UPDATE /api/room-mood:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


// Get full room_status row for debugging (includes timestamps)
// Example: GET /api/room-status/1
router.get('/api/room-status/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const [rows] = await pool.query(
      `SELECT user_id,
              plant_status,
              dog_status,
              window_status,
              room_mood,
              last_plant_update,
              last_dog_update,
              last_window_update,
              last_room_update,
              last_plant_read,
              last_dog_read,
              last_window_read,
              last_room_read,
              updated_at
       FROM room_status
       WHERE user_id = ?`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ ok: false, error: 'User not found' });
    }

    return res.json({
      ok: true,
      room_status: rows[0],
    });
  } catch (err) {
    console.error('DB error in /api/room-status:', err);
    return res.status(500).json({ ok: false, error: 'Database error' });
  }
});


module.exports = router;