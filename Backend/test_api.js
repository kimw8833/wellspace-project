// test_api.js
// A simple script to test all API endpoints for the Wellspace backend.
// This script performs GET and PUT requests to verify that the server,
// database connection, login, and status update routes are functioning correctly.

const axios = require('axios');
require('dotenv').config();

// Load API base URL from .env, fallback to ngrok if not found
const API_BASE_URL =
  process.env.API_BASE_URL ||
  'https://paragogically-unlegible-grazyna.ngrok-free.dev';

async function testAPI() {
  try {
    // Test user info
    const testUserId = 1;
    const testUsername = 'Kim';
    const testPassword = '1234';

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

    const loggedInUser = loginRes.data.user;
    console.log('Logged in user:', loggedInUser);

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
      { window_status: 1.00 },
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
