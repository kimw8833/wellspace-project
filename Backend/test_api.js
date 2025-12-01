// test_api.js
const axios = require('axios');
require('dotenv').config(); // Read value API_BASE_URL from .env

// Incase .env does not exist API_BASE_URL will use ngrok URL or localhost
const API_BASE_URL = process.env.API_BASE_URL || 'https://paragogically-unlegible-grazyna.ngrok-free.dev';

async function testAPI() {
  try {
    const testUserId = 1;        // user_id
    const testUsername = 'Kim';  // username 
    const testPassword = '1234'; // password

    //
    // 1) /api/ping
    //
    console.log('\n🔹 Testing GET /api/ping ...');
    let pingRes = await axios.get(`${API_BASE_URL}/api/ping`);
    console.log('✅ /api/ping response:', pingRes.data);

    //
    // 2) /api/test-db
    //
    console.log('\n🔹 Testing GET /api/test-db ...');
    let dbRes = await axios.get(`${API_BASE_URL}/api/test-db`);
    console.log('✅ /api/test-db response:', dbRes.data);

    //
    // 3) /api/users
    //
    console.log('\n🔹 Testing GET /api/users ...');
    let usersRes = await axios.get(`${API_BASE_URL}/api/users`);
    console.log('✅ /api/users response:', usersRes.data);

    //
    // 4) /api/login
    //
    console.log('\n🔹 Testing POST /api/login ...');
    let loginRes = await axios.post(
      `${API_BASE_URL}/api/login`,
      {
        username: testUsername,
        password: testPassword,
      },
      {
        headers: { 'Content-Type': 'application/json' },
      }
    );
    console.log('✅ /api/login response:', loginRes.data);

    const loggedInUser = loginRes.data.user;
    console.log('👤 Logged in user:', loggedInUser);

    //
    // 5) /api/dog-status/:userId
    //
    console.log(`\n🔹 Testing GET /api/dog-status/${testUserId} ...`);
    let dogRes = await axios.get(`${API_BASE_URL}/api/dog-status/${testUserId}`);
    console.log('✅ /api/dog-status response:', dogRes.data);

    if (dogRes.data.ok === true) {
      console.log(`🐶 Dog status for user ${testUserId} =`, dogRes.data.dog_status);
    } else {
      console.log('⚠️ ok=false from /api/dog-status:', dogRes.data);
    }

    //
    // 6) /api/room-mood/:userId
    //
    console.log(`\n🔹 Testing GET /api/room-mood/${testUserId} ...`);
    let roomRes = await axios.get(`${API_BASE_URL}/api/room-mood/${testUserId}`);
    console.log('✅ /api/room-mood response:', roomRes.data);

    if (roomRes.data.ok === true) {
      console.log(`Room Mood for user ${testUserId} =`, roomRes.data.room_mood);
    } else {
      console.log('⚠️ ok=false from /api/room-mood:', roomRes.data);
    }














    console.log('\n🎉 All tests finished!\n');

  } catch (error) {
    console.error('\n❌ Error while testing API');

    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data  :', error.response.data);
    } else {
      console.error('Message:', error.message);
    }
  }
}

testAPI();
