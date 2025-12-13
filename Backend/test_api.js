// Backend/test_api.js

// A simple script to test all API endpoints for the Wellspace backend.
// This script performs GET and PUT requests to verify that the server,
// database connection, login, and status update routes are functioning correctly.

const axios = require('axios');
require('dotenv').config();

// Load API base URL from .env, fallback to ngrok if not found
const API_BASE_URL =
  process.env.API_BASE_URL ||
  'https://paragogically-unlegible-grazyna.ngrok-free.dev';

// -------------------------------
// FRIEND TEST HELPERS
// -------------------------------

function findUserId(usersData, username) {
  // usersRes.data อาจเป็น { ok:true, users:[...] } หรือเป็น array ตรง ๆ
  const users = Array.isArray(usersData) ? usersData : usersData?.users;
  if (!Array.isArray(users)) return null;

  const u = users.find((x) => x.username === username);
  return u ? u.id : null;
}

async function sendFriendRequest(userId, friendUsername) {
  const res = await axios.post(
    `${API_BASE_URL}/api/friends/add`,
    { userId, friendUsername },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log(`Response:`, res.data);
  return res.data;
}

async function getIncomingFriendRequests(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/friend-requests/${userId}`);
  console.log(`Response:`, res.data);
  return res.data;
}

async function acceptFriendRequest(userId, requesterId) {
  const res = await axios.post(
    `${API_BASE_URL}/api/friends/accept`,
    { userId, requesterId },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log(`Response:`, res.data);
  return res.data;
}

async function getFriendsList(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/friends/${userId}`);
  console.log(`Response:`, res.data);
  return res.data;
}

async function removeFriend(userId, friendId) {
  // axios.delete ต้องส่ง body ผ่าน { data: ... }
  const res = await axios.delete(`${API_BASE_URL}/api/friends`, {
    data: { userId, friendId },
    headers: { 'Content-Type': 'application/json' },
  });
  console.log(`Response:`, res.data);
  return res.data;
}

async function testAPI() {
  try {
    // Test user info
    const testUsername = 'Kim';
    const testPassword = '1234';
    let testUserId; // จะเซ็ตหลังจาก login สำเร็จ

    // ------------------------------------------------------------
    // 1. Test server availability
    // ------------------------------------------------------------
    console.log('\n🔹 Testing GET /api/ping ...');
    const pingRes = await axios.get(`${API_BASE_URL}/api/ping`);
    console.log('Response:', pingRes.data);

    // ------------------------------------------------------------
    // 2. Test database connection
    // ------------------------------------------------------------
    console.log('\n🔹 Testing GET /api/test-db ...');
    const dbRes = await axios.get(`${API_BASE_URL}/api/test-db`);
    console.log('Response:', dbRes.data);

    // ------------------------------------------------------------
    // 3. Fetch all users (simple check without passwords)
    // ------------------------------------------------------------
    console.log('\n🔹 Testing GET /api/users ...');
    const usersRes = await axios.get(`${API_BASE_URL}/api/users`);
    console.log('Response:', usersRes.data);

    // ------------------------------------------------------------
    // 4. Test login using username + password
    // ------------------------------------------------------------
    console.log('\n🔹 Testing POST /api/login ...');
    const loginRes = await axios.post(
      `${API_BASE_URL}/api/login`,
      { username: testUsername, password: testPassword },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', loginRes.data);

    if (!loginRes.data.ok) {
      console.error('Login failed, aborting tests.');
      return;
    }

    const loggedInUser = loginRes.data.user;
    console.log('Logged in user:', loggedInUser);

    // ใช้ id จาก login ให้ตรงกับ DB เสมอ (Kim = 2 ตอนนี้)
    testUserId = loggedInUser.id;
    console.log('Using testUserId =', testUserId);

    // ------------------------------------------------------------
    // 5. GET plant status
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/plant-status/${testUserId} ...`);
    let plantRes = await axios.get(`${API_BASE_URL}/api/plant-status/${testUserId}`);
    console.log('Response:', plantRes.data);

    // ------------------------------------------------------------
    // 6. GET dog status
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/dog-status/${testUserId} ...`);
    let dogRes = await axios.get(`${API_BASE_URL}/api/dog-status/${testUserId}`);
    console.log('Response:', dogRes.data);

    // ------------------------------------------------------------
    // 7. GET window status
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/window-status/${testUserId} ...`);
    let windowRes = await axios.get(`${API_BASE_URL}/api/window-status/${testUserId}`);
    console.log('Response:', windowRes.data);

    // ------------------------------------------------------------
    // 8. GET room mood
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/room-mood/${testUserId} ...`);
    let roomRes = await axios.get(`${API_BASE_URL}/api/room-mood/${testUserId}`);
    console.log('Response:', roomRes.data);

    // ------------------------------------------------------------
    // 9. UPDATE plant status
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/plant-status/${testUserId} ...`);
    const updatePlantRes = await axios.put(
      `${API_BASE_URL}/api/plant-status/${testUserId}`,
      { plant_status: 0.25 },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updatePlantRes.data);

    // ------------------------------------------------------------
    // 10. UPDATE dog status
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/dog-status/${testUserId} ...`);
    const updateDogRes = await axios.put(
      `${API_BASE_URL}/api/dog-status/${testUserId}`,
      { dog_status: 0.50 },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updateDogRes.data);

    // ------------------------------------------------------------
    // 11. UPDATE window status
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/window-status/${testUserId} ...`);
    const updateWindowRes = await axios.put(
      `${API_BASE_URL}/api/window-status/${testUserId}`,
      { window_status: 1.0 },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updateWindowRes.data);

    // ------------------------------------------------------------
    // 12. UPDATE room mood
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/room-mood/${testUserId} ...`);
    const updateRoomRes = await axios.put(
      `${API_BASE_URL}/api/room-mood/${testUserId}`,
      { room_mood: 0.75 },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updateRoomRes.data);

    // ------------------------------------------------------------
    // 13. Re-check all updated statuses
    // ------------------------------------------------------------
    console.log('\n🔹 Re-checking statuses after updates ...');

    plantRes = await axios.get(`${API_BASE_URL}/api/plant-status/${testUserId}`);
    dogRes = await axios.get(`${API_BASE_URL}/api/dog-status/${testUserId}`);
    windowRes = await axios.get(`${API_BASE_URL}/api/window-status/${testUserId}`);
    roomRes = await axios.get(`${API_BASE_URL}/api/room-mood/${testUserId}`);

    console.log('Plant status  :', plantRes.data.plant_status);
    console.log('Dog status    :', dogRes.data.dog_status);
    console.log('Window status :', windowRes.data.window_status);
    console.log('Room mood     :', roomRes.data.room_mood);

    // ------------------------------------------------------------
    // 14. Fetch full room_status row to inspect timestamps
    // ------------------------------------------------------------
    console.log(`\n🔹 Fetching full room_status for user ${testUserId} ...`);
    const fullStatusRes = await axios.get(
      `${API_BASE_URL}/api/room-status/${testUserId}`
    );
    console.log('Response:', fullStatusRes.data);

    const rs = fullStatusRes.data.room_status;
    console.log('\nCurrent room_status row:');
    console.log('user_id             :', rs.user_id);
    console.log('plant_status        :', rs.plant_status);
    console.log('dog_status          :', rs.dog_status);
    console.log('window_status       :', rs.window_status);
    console.log('room_mood           :', rs.room_mood);
    console.log('last_plant_update   :', rs.last_plant_update);
    console.log('last_dog_update     :', rs.last_dog_update);
    console.log('last_window_update  :', rs.last_window_update);
    console.log('last_room_update    :', rs.last_room_update);
    console.log('last_plant_read     :', rs.last_plant_read);
    console.log('last_dog_read       :', rs.last_dog_read);
    console.log('last_window_read    :', rs.last_window_read);
    console.log('last_room_read      :', rs.last_room_read);
    console.log('updated_at          :', rs.updated_at);

    // ------------------------------------------------------------
    // 15. GET step_goal
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/step-goal/${testUserId} ...`);
    let stepGoalRes = await axios.get(
      `${API_BASE_URL}/api/step-goal/${testUserId}`
    );
    console.log('Response:', stepGoalRes.data);

    // ------------------------------------------------------------
    // 16. UPDATE step_goal
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/step-goal/${testUserId} ...`);
    const newStepGoal = 6000;
    const updateStepGoalRes = await axios.put(
      `${API_BASE_URL}/api/step-goal/${testUserId}`,
      { step_goal: newStepGoal },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updateStepGoalRes.data);

    // Re-check step_goal
    stepGoalRes = await axios.get(
      `${API_BASE_URL}/api/step-goal/${testUserId}`
    );
    console.log('Re-checked step_goal:', stepGoalRes.data.step_goal);

    // ------------------------------------------------------------
    // 17. GET waterintake_goal
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/waterintake-goal/${testUserId} ...`);
    let waterGoalRes = await axios.get(
      `${API_BASE_URL}/api/waterintake-goal/${testUserId}`
    );
    console.log('Response:', waterGoalRes.data);

    // ------------------------------------------------------------
    // 18. UPDATE waterintake_goal
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/waterintake-goal/${testUserId} ...`);
    const newWaterGoal = 2500;
    const updateWaterGoalRes = await axios.put(
      `${API_BASE_URL}/api/waterintake-goal/${testUserId}`,
      { waterintake_goal: newWaterGoal },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updateWaterGoalRes.data);

    // Re-check waterintake_goal
    waterGoalRes = await axios.get(
      `${API_BASE_URL}/api/waterintake-goal/${testUserId}`
    );
    console.log('Re-checked waterintake_goal:', waterGoalRes.data.waterintake_goal);

    // ------------------------------------------------------------
    // 19. GET user_location
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing GET /api/user-location/${testUserId} ...`);
    let ulRes = await axios.get(
      `${API_BASE_URL}/api/user-location/${testUserId}`
    );
    console.log('Response:', ulRes.data);

    // ------------------------------------------------------------
    // 20. UPDATE user_location
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing PUT /api/user-location/${testUserId} ...`);
    const newUserLocation = ulRes.data.user_location === 'inside'
      ? 'outside'
      : 'inside';

    const updateUlRes = await axios.put(
      `${API_BASE_URL}/api/user-location/${testUserId}`,
      { user_location: newUserLocation },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log('Response:', updateUlRes.data);

    // Re-check user_location
    ulRes = await axios.get(
      `${API_BASE_URL}/api/user-location/${testUserId}`
    );
    console.log('Re-checked user_location:', ulRes.data.user_location);
  
    // ------------------------------------------------------------
    // 21. FRIENDS FLOW TEST (Final Pattern)
    // Kim sends request to Tommy -> Tommy accepts -> list -> remove
    // ------------------------------------------------------------
    console.log('\n🔹 Testing FRIENDS flow ...');

    // ใช้ usersRes ที่เพิ่งดึงมา (step 3)
    const kimId = findUserId(usersRes.data, 'Kim');
    const tommyId = findUserId(usersRes.data, 'Tommy');

    if (!kimId || !tommyId) {
      console.log('Cannot find Kim or Tommy in /api/users. Skipping friends test.');
    } else {
      console.log(`Using Kim id=${kimId}, Tommy id=${tommyId}`);

      // 21.1 Kim sends friend request to Tommy (ใช้ username)
      console.log('\n   🔸 21.1 POST /api/friends/add (Kim -> Tommy) ...');
      await sendFriendRequest(kimId, 'Tommy');

      // 21.2 Tommy checks incoming requests
      console.log('\n   🔸 21.2 GET /api/friend-requests/:userId (Tommy incoming) ...');
      const incoming = await getIncomingFriendRequests(tommyId);

      const requests = incoming?.requests || [];
      const reqFromKim = requests.find((r) => r.requester_id === kimId);

      if (!reqFromKim) {
        console.log('No pending request from Kim found for Tommy. (Maybe already accepted or not created)');
      } else {
        // 21.3 Tommy accepts (ใช้ ids)
        console.log('\n   🔸 21.3 POST /api/friends/accept (Tommy accepts Kim) ...');
        await acceptFriendRequest(tommyId, kimId);

        // 21.4 List friends for both
        console.log('\n   🔸 21.4 GET /api/friends/:userId (Kim friends) ...');
        await getFriendsList(kimId);

        console.log('\n   🔸 21.5 GET /api/friends/:userId (Tommy friends) ...');
        await getFriendsList(tommyId);

        // 21.6 Remove friend (จากฝั่ง Kim ก็ได้)
        console.log('\n   🔸 21.6 DELETE /api/friends (Kim removes Tommy) ...');
        await removeFriend(kimId, tommyId);

        // 21.7 Re-check lists
        console.log('\n   🔸 21.7 Re-check GET /api/friends/:userId (Kim) ...');
        await getFriendsList(kimId);

        console.log('\n   🔸 21.8 Re-check GET /api/friends/:userId (Tommy) ...');
        await getFriendsList(tommyId);
      }
    }


    // ------------------------------------------------------------
    console.log('\nAll tests finished.\n');

  } catch (error) {
    console.error('\nError while testing API');

    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data  :', error.response.data);
    } else {
      console.error('Message:', error.message);
    }
  }
}

testAPI();
