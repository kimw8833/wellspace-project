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
// COIN TEST HELPERS
// -------------------------------
async function getUserCoin(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/users/${userId}/coin`);
  console.log('helper getUserCoin Response:', res.data);
  return res.data;
}

async function updateUserCoin(userId, coin) {
  const res = await axios.put(
    `${API_BASE_URL}/api/users/${userId}/coin`,
    { coin },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log('helper updateUserCoin Response:', res.data);
  return res.data;
}

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

async function rejectFriendRequest(userId, requesterId) {
  const res = await axios.post(
    `${API_BASE_URL}/api/friends/reject`,
    { userId, requesterId },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log(`Response:`, res.data);
  return res.data;
}

// -------------------------------
// AUTH TEST HELPERS
// -------------------------------
function makeRandomUsername(prefix = 'WellspaceUser') {
  return `${prefix}_${Date.now()}`;
}

async function registerUser(username, password) {
  const res = await axios.post(
    `${API_BASE_URL}/api/register`,
    { username, password },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log('Response:', res.data);
  return res.data;
}

async function loginUser(username, password) {
  const res = await axios.post(
    `${API_BASE_URL}/api/login`,
    { username, password },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log('Response:', res.data);
  return res.data;
}

async function deleteUser(userId) {
  const res = await axios.delete(`${API_BASE_URL}/api/users/${userId}`);
  console.log('Response:', res.data);
  return res.data;
}

// -------------------------------
// ACHIEVEMENTS TEST HELPERS
// -------------------------------
async function getAchievements(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/achievements/${userId}`);
  console.log('helper getAchievements Response:', res.data);
  return res.data;
}

async function updateAchievementProgress(userId, index, progress) {
  const res = await axios.put(
    `${API_BASE_URL}/api/achievements/${userId}/${index}`,
    { progress },
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log('helper updateAchievementProgress Response:', res.data);
  return res.data;
}

// -------------------------------
// MAIN TEST FLOW
// -------------------------------
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
    // 3.1 REGISTER + LOGIN + VERIFY room_status + cleanup delete
    // ------------------------------------------------------------
    console.log('\n🔹 Testing REGISTER flow (new random user) ...');

    const newUsername = makeRandomUsername('WellspaceUser');
    const newPassword = '1234';
    let newUserId = null;

    // 3.1.1 Register
    try {
      const regData = await registerUser(newUsername, newPassword);

      // รองรับ ok:true หรือ success:true (เผื่อคุณเคยใช้ 2 แบบ)
      const ok = regData?.ok === true || regData?.success === true;

      if (!ok || !regData?.user?.id) {
        console.log('Register did not return user id. Response:', regData);
      } else {
        newUserId = regData.user.id;
        console.log(`Registered new user: ${newUsername} (id=${newUserId})`);
      }
    } catch (error) {
      console.log('Register failed.');
      if (error.response) {
        console.log('Status:', error.response.status);
        console.log('Data  :', error.response.data);
      } else {
        console.log('Message:', error.message);
      }
    }

    // 3.1.2 Login with new user
    if (newUserId) {
      console.log('\n🔹 Testing POST /api/login (new user) ...');

      try {
        const loginData = await loginUser(newUsername, newPassword);
        const okLogin = loginData?.ok === true || loginData?.success === true;

        if (!okLogin) {
          console.log('New user login failed. Response:', loginData);
        } else {
          console.log('New user login OK:', loginData.user);
        }
      } catch (e) {
        console.log('Login request failed.');
        if (e.response) {
          console.log('Status:', e.response.status);
          console.log('Data  :', e.response.data);
        } else {
          console.log('Message:', e.message);
        }
      }

      // 3.1.3 Verify room_status row exists
      console.log(`\n🔹 Verifying room_status (GET /api/room-status/${newUserId}) ...`);
      let verified = false;

      try {
        const rsRes = await axios.get(`${API_BASE_URL}/api/room-status/${newUserId}`);
        console.log('Response:', rsRes.data);
        console.log('room_status exists for new user.');
        verified = true;
      } catch (e) {
        console.log('/api/room-status failed. Trying /api/plant-status instead...');

        try {
          const plantRes2 = await axios.get(`${API_BASE_URL}/api/plant-status/${newUserId}`);
          console.log('Response:', plantRes2.data);
          console.log('plant-status works => room_status row likely exists.');
          verified = true;
        } catch (e2) {
          console.log('Could not verify room_status for new user.');
          if (e2.response) {
            console.log('Status:', e2.response.status);
            console.log('Data  :', e2.response.data);
          } else {
            console.log('Message:', e2.message);
          }
        }
      }

      // 3.1.4 Optional: update plant_status
      if (verified) {
        console.log(`\n🔹 Optional sanity: PUT /api/plant-status/${newUserId} ...`);
        try {
          const upd = await axios.put(
            `${API_BASE_URL}/api/plant-status/${newUserId}`,
            { plant_status: 0.10 },
            { headers: { 'Content-Type': 'application/json' } }
          );
          console.log('Response:', upd.data);
        } catch (e) {
          console.log('PUT plant-status failed (route not implemented?). Skipping.');
        }
      }

      // 3.1.5 DELETE USER (cleanup)
      console.log(`\n🔹 Cleanup: DELETE /api/users/${newUserId} ...`);
      try {
        const delRes = await deleteUser(newUserId);
        if (delRes?.ok) {
          console.log('User deleted successfully.');
        } else {
          console.log('Unexpected delete response:', delRes);
        }
      } catch (e) {
        console.log('Delete failed.');
        if (e.response) {
          console.log('Status:', e.response.status);
          console.log('Data  :', e.response.data);
        } else {
          console.log('Message:', e.message);
        }
      }
    }



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
    // X. ACHIEVEMENTS FLOW TEST
    // GET -> PUT (upsert) -> GET -> invalid cases
    // ------------------------------------------------------------
    console.log('\n🔹 Testing ACHIEVEMENTS flow ...');

    try {
      // X.1 GET achievements before update
      console.log(`\n   🔸 X.1 GET /api/achievements/${testUserId} (before) ...`);
      const achBefore = await getAchievements(testUserId);

      const listBefore = achBefore?.achievements || [];
      console.log('Achievements BEFORE:', listBefore);

      // X.2 PUT updates (should work even if row not seeded because we upsert)
      console.log(`\n   🔸 X.2 PUT /api/achievements/${testUserId}/1 progress=55 ...`);
      await updateAchievementProgress(testUserId, 1, 55);

      console.log(`\n   🔸 X.3 PUT /api/achievements/${testUserId}/2 progress=100 ...`);
      await updateAchievementProgress(testUserId, 2, 100);

      // X.3 GET achievements after update
      console.log(`\n   🔸 X.4 GET /api/achievements/${testUserId} (after) ...`);
      const achAfter = await getAchievements(testUserId);
      const listAfter = achAfter?.achievements || [];
      console.log('Achievements AFTER:', listAfter);

      // Soft asserts
      const a1 = listAfter.find(x => x.achievement_index === 1);
      const a2 = listAfter.find(x => x.achievement_index === 2);

      if (!a1 || a1.progress !== 55) {
        console.log('FAIL: index=1 progress expected 55 but got:', a1);
      } else {
        console.log('OK: index=1 progress is 55');
      }

      if (!a2 || a2.progress !== 100) {
        console.log('FAIL: index=2 progress expected 100 but got:', a2);
      } else {
        console.log('OK: index=2 progress is 100 (done = true in frontend)');
      }

      // X.4 Invalid progress
      console.log(`\n   🔸 X.5 PUT invalid progress=150 (should be 400) ...`);
      try {
        await updateAchievementProgress(testUserId, 1, 150);
        console.log('FAIL: invalid progress=150 should not succeed');
      } catch (e) {
        console.log('OK: invalid progress rejected');
        if (e.response) {
          console.log('Status:', e.response.status);
          console.log('Data  :', e.response.data);
        } else {
          console.log('Message:', e.message);
        }
      }

      // X.5 Invalid userId
      console.log(`\n   🔸 X.6 GET invalid userId=-1 (should be 400) ...`);
      try {
        await getAchievements(-1);
        console.log('FAIL: invalid userId=-1 should not succeed');
      } catch (e) {
        console.log('OK: invalid userId rejected');
        if (e.response) {
          console.log('Status:', e.response.status);
          console.log('Data  :', e.response.data);
        } else {
          console.log('Message:', e.message);
        }
      }

    } catch (e) {
      console.log('Achievements flow failed unexpectedly.');
      if (e.response) {
        console.log('Status:', e.response.status);
        console.log('Data  :', e.response.data);
      } else {
        console.log('Message:', e.message);
      }
    }

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
    // 20.1 COIN FLOW TEST (GET -> PUT -> GET)
    // ------------------------------------------------------------
    console.log(`\n🔹 Testing COIN flow ...`);

    try {
      // 20.1.1 GET coin before
      console.log(`\n   🔸 GET /api/users/${testUserId}/coin (before) ...`);
      const coinBeforeRes = await getUserCoin(testUserId);
      const coinBefore = coinBeforeRes?.coin;

      console.log('Coin BEFORE:', coinBefore);

      // 20.1.2 PUT coin update (set new value)
      const newCoinValue = (typeof coinBefore === 'number' ? coinBefore : 0) + 10;
      console.log(`\n   🔸 PUT /api/users/${testUserId}/coin (set coin=${newCoinValue}) ...`);
      await updateUserCoin(testUserId, newCoinValue);

      // 20.1.3 GET coin after
      console.log(`\n   🔸 GET /api/users/${testUserId}/coin (after) ...`);
      const coinAfterRes = await getUserCoin(testUserId);
      const coinAfter = coinAfterRes?.coin;

      console.log('Coin AFTER:', coinAfter);

      // Soft assert
      if (coinAfter !== newCoinValue) {
        console.log(`FAIL: coin expected ${newCoinValue} but got`, coinAfter);
      } else {
        console.log('OK: coin updated correctly');
      }

      // 20.1.4 Negative test: missing coin body
      console.log(`\n   🔸 Negative: PUT /api/users/${testUserId}/coin without coin (should be 400) ...`);
      try {
        await axios.put(
          `${API_BASE_URL}/api/users/${testUserId}/coin`,
          {}, // missing coin
          { headers: { 'Content-Type': 'application/json' } }
        );
        console.log('FAIL: missing coin should not succeed');
      } catch (e) {
        console.log('OK: missing coin rejected');
        if (e.response) {
          console.log('Status:', e.response.status);
          console.log('Data  :', e.response.data);
        } else {
          console.log('Message:', e.message);
        }
      }

      // 20.1.5 Negative test: invalid userId
      console.log(`\n   🔸 Negative: GET /api/users/-1/coin (should be 404 or 400) ...`);
      try {
        await getUserCoin(-1);
        console.log('FAIL: invalid userId should not succeed');
      } catch (e) {
        console.log('OK: invalid userId rejected');
        if (e.response) {
          console.log('Status:', e.response.status);
          console.log('Data  :', e.response.data);
        } else {
          console.log('Message:', e.message);
        }
      }

    } catch (e) {
      console.log('Coin flow failed unexpectedly.');
      if (e.response) {
        console.log('Status:', e.response.status);
        console.log('Data  :', e.response.data);
      } else {
        console.log('Message:', e.message);
      }
    }

    // ------------------------------------------------------------
    // 21. FRIENDS FLOW TEST (Final Pattern)
    // Kim sends request to Tommy -> Tommy accepts -> list -> remove
    // ------------------------------------------------------------
    console.log('\n🔹 Testing FRIENDS flow ...');

    // Use usersRes from step 3 to find Kim and Tommy ids
    const kimId = findUserId(usersRes.data, 'Kim');
    const tommyId = findUserId(usersRes.data, 'Tommy');

    if (!kimId || !tommyId) {
      console.log('Cannot find Kim or Tommy in /api/users. Skipping friends test.');
    } else {
      console.log(`Using Kim id=${kimId}, Tommy id=${tommyId}`);

      // 21.1 Kim sends friend request to Tommy (Use username)
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
        // 21.3 Tommy accepts (Use ids)
        console.log('\n   🔸 21.3 POST /api/friends/accept (Tommy accepts Kim) ...');
        await acceptFriendRequest(tommyId, kimId);

        // 21.4 List friends for both
        console.log('\n   🔸 21.4 GET /api/friends/:userId (Kim friends) ...');
        await getFriendsList(kimId);

        console.log('\n   🔸 21.5 GET /api/friends/:userId (Tommy friends) ...');
        await getFriendsList(tommyId);

        // 21.6 Remove friend (From Kim side)
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
    // 22. FRIENDS RESEND TEST (Reject -> Resend -> Accept)
    // Kim -> Tommy (send) -> Tommy reject -> Kim resend -> Tommy accept
    // ------------------------------------------------------------
    console.log('\n🔹 Testing FRIENDS resend flow (reject then resend) ...');

    if (!kimId || !tommyId) {
      console.log('Cannot find Kim or Tommy in /api/users. Skipping resend test.');
    } else {
      console.log(`Using Kim id=${kimId}, Tommy id=${tommyId}`);

      // 22.0 Cleanup: if already friends, remove (ignore errors)
      console.log('\n   🔸 22.0 Cleanup: ensure not already friends ...');
      try { await removeFriend(kimId, tommyId); } catch (e) {}
      try { await removeFriend(tommyId, kimId); } catch (e) {}

      // 22.1 Kim sends request
      console.log('\n   🔸 22.1 POST /api/friends/add (Kim -> Tommy) ...');
      await sendFriendRequest(kimId, 'Tommy');

      // 22.2 Tommy checks incoming + reject
      console.log('\n   🔸 22.2 GET incoming (Tommy) then REJECT ...');
      let incoming1 = await getIncomingFriendRequests(tommyId);
      let req1 = (incoming1?.requests || []).find(r => r.requester_id === kimId);

      if (!req1) {
        console.log('No pending request from Kim found (cannot reject).');
      } else {
        console.log('\n   🔸 22.3 POST /api/friends/reject (Tommy rejects Kim) ...');
        await rejectFriendRequest(tommyId, kimId);

        // 22.4 Kim resends request (THIS IS THE BUGFIX TEST)
        console.log('\n   🔸 22.4 POST /api/friends/add AGAIN (Kim -> Tommy) ...');
        const resendRes = await sendFriendRequest(kimId, 'Tommy');

        // soft assert
        const msg = (resendRes?.message || '').toLowerCase();
        if (msg.includes('existing relationship status: rejected')) {
          console.log('FAIL: Still blocked by rejected status (bugfix not applied).');
        } else {
          console.log('OK: Resend did not get blocked by rejected status.');
        }

        // 22.5 Tommy should see incoming again
        console.log('\n   🔸 22.5 GET incoming again (Tommy) ...');
        let incoming2 = await getIncomingFriendRequests(tommyId);
        let req2 = (incoming2?.requests || []).find(r => r.requester_id === kimId);

        if (!req2) {
          console.log('FAIL: No pending request after resend.');
        } else {
          console.log('OK: Pending request exists after resend.');

          // 22.6 Accept
          console.log('\n   🔸 22.6 POST /api/friends/accept (Tommy accepts Kim) ...');
          await acceptFriendRequest(tommyId, kimId);

          // 22.7 Check friends list
          console.log('\n   🔸 22.7 GET /api/friends/:userId (Kim friends) ...');
          await getFriendsList(kimId);

          console.log('\n   🔸 22.8 GET /api/friends/:userId (Tommy friends) ...');
          await getFriendsList(tommyId);

          // 22.9 Cleanup remove friend
          console.log('\n   🔸 22.9 Cleanup: DELETE /api/friends (Kim removes Tommy) ...');
          await removeFriend(kimId, tommyId);
        }
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
