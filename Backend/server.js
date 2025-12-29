// Backend/server.js

const express = require('express');
const cors = require('cors');

const goalsRoutes   = require('./routes/goals.routes');
const roomRoutes    = require('./routes/room.routes');
const authRoutes    = require('./routes/auth.routes');
const miscRoutes    = require('./routes/misc.routes');
const friendsRoutes = require('./routes/friends.routes');
const achievementsRoutes = require('./routes/achievements.routes');
const cointRoutes = require('./routes/coin.routes');


const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.use(goalsRoutes);
app.use(roomRoutes);
app.use(authRoutes);
app.use(miscRoutes);
app.use(friendsRoutes);
app.use(achievementsRoutes);
app.use(cointRoutes);

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});