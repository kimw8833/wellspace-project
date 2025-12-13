const express = require('express');
const cors = require('cors');

const goalsRoutes = require('./routes/goals.routes');
const roomRoutes  = require('./routes/room.routes');
const authRoutes  = require('./routes/auth.routes');
const miscRoutes  = require('./routes/misc.routes');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.use(goalsRoutes);
app.use(roomRoutes);
app.use(authRoutes);
app.use(miscRoutes);

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});