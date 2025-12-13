> node server.js
> node test_api.js

Example:
last_plant_update: 2025-12-06T12:14:21.532Z

06 DEC 2025 time 12:14:21 (hour:minute:secound)

.532 means 532 milliseconds
Z means UTC timezone


backend/
  server.js
  db/
    pool.js
  routes/
    goals.routes.js
    room.routes.js
    auth.routes.js
    misc.routes.js
    friends.routes.js