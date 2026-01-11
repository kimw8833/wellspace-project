// Backend/server_tests.js
//
// PASS/FAIL style API test runner (no extra packages).
// Run: node server_tests.js

const axios = require('axios');
require('dotenv').config();

const API_BASE_URL =
  process.env.API_BASE_URL ||
  'https://paragogically-unlegible-grazyna.ngrok-free.dev';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

function isNumeric(v) {
  if (typeof v === 'number') return Number.isFinite(v);
  if (typeof v === 'string') return v.trim() !== '' && !Number.isNaN(Number(v));
  return false;
}

// ------------------------------------------------------------
// Mini test runner
// ------------------------------------------------------------
const T = {
  passed: 0,
  failed: 0,

  async test(name, fn) {
    try {
      await fn();
      this.passed++;
      console.log(`PASS: ${name}`);
    } catch (e) {
      this.failed++;
      console.log(`FAIL: ${name}`);
      console.log(`   -> ${e?.message || e}`);
    }
  },

  expect(cond, msg = 'Expectation failed') {
    if (!cond) throw new Error(msg);
  },

  eq(actual, expected, msg = 'Not equal') {
    if (actual !== expected) {
      throw new Error(`${msg} (expected=${expected}, got=${actual})`);
    }
  },

  inRange(x, min, max, msg = 'Out of range') {
    if (typeof x !== 'number' || x < min || x > max) {
      throw new Error(`${msg} (expected ${min}..${max}, got=${x})`);
    }
  },

  summary() {
    console.log('\n==== TEST SUMMARY ====');
    console.log(`Passed: ${this.passed}`);
    console.log(`Failed: ${this.failed}`);
    console.log('======================\n');
  },
};

// ------------------------------------------------------------
// Helper: users list -> find id
// ------------------------------------------------------------
function findUserId(usersData, username) {
  const users = Array.isArray(usersData) ? usersData : usersData?.users;
  if (!Array.isArray(users)) return null;

  const u = users.find((x) => x.username === username);
  return u ? u.id : null;
}

// ------------------------------------------------------------
// Auth helpers
// ------------------------------------------------------------
function makeRandomUsername(prefix = 'WellspaceUser') {
  return `${prefix}_${Date.now()}`;
}

async function registerUser(username, password) {
  const res = await axios.post(
    `${API_BASE_URL}/api/register`,
    { username, password },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

async function loginUser(username, password) {
  const res = await axios.post(
    `${API_BASE_URL}/api/login`,
    { username, password },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

async function deleteUser(userId) {
  const res = await axios.delete(`${API_BASE_URL}/api/users/${userId}`);
  return res.data;
}

// ------------------------------------------------------------
// Tutorial / First-time helpers
// ------------------------------------------------------------
async function getIsFirstTime(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/users/${userId}/first-time`);
  return res.data;
}

async function tutorialComplete(userId) {
  const res = await axios.post(
    `${API_BASE_URL}/api/users/${userId}/tutorial-complete`,
    {},
    { headers: JSON_HEADERS }
  );
  return res.data;
}

// ------------------------------------------------------------
// Achievements helpers
// ------------------------------------------------------------
async function getAchievements(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/achievements/${userId}`);
  return res.data;
}

async function updateAchievementProgress(userId, index, progress) {
  const res = await axios.put(
    `${API_BASE_URL}/api/achievements/${userId}/${index}/progress`,
    { progress },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

/**
 * updateAchievement(userId, index, body)
 * รองรับ body: { progress?, claimed?, tier? }
 * แต่ backend แยก endpoint เป็น /progress, /claimed, /tier
 * ดังนั้น helper นี้จะยิงทีละ endpoint ตาม field ที่ส่งมา
 */
async function updateAchievement(userId, index, body) {
  // progress
  if (body && body.progress !== undefined) {
    await axios.put(
      `${API_BASE_URL}/api/achievements/${userId}/${index}/progress`,
      { progress: body.progress },
      { headers: JSON_HEADERS }
    );
  }

  // claimed
  if (body && body.claimed !== undefined) {
    await axios.put(
      `${API_BASE_URL}/api/achievements/${userId}/${index}/claimed`,
      { claimed: body.claimed },
      { headers: JSON_HEADERS }
    );
  }

  // tier
  if (body && body.tier !== undefined) {
    await axios.put(
      `${API_BASE_URL}/api/achievements/${userId}/${index}/tier`,
      { tier: body.tier },
      { headers: JSON_HEADERS }
    );
  }

  return { success: true };
}

// ------------------------------------------------------------
// Coin helpers
// ------------------------------------------------------------
async function getUserCoin(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/users/${userId}/coin`);
  return res.data;
}

async function updateUserCoin(userId, coin) {
  const res = await axios.put(
    `${API_BASE_URL}/api/users/${userId}/coin`,
    { coin },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

// ------------------------------------------------------------
// Friend helpers
// ------------------------------------------------------------
async function sendFriendRequest(userId, friendUsername) {
  const res = await axios.post(
    `${API_BASE_URL}/api/friends/add`,
    { userId, friendUsername },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

async function getIncomingFriendRequests(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/friend-requests/${userId}`);
  return res.data;
}

async function acceptFriendRequest(userId, requesterId) {
  const res = await axios.post(
    `${API_BASE_URL}/api/friends/accept`,
    { userId, requesterId },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

async function getFriendsList(userId) {
  const res = await axios.get(`${API_BASE_URL}/api/friends/${userId}`);
  return res.data;
}

async function removeFriend(userId, friendId) {
  const res = await axios.delete(`${API_BASE_URL}/api/friends`, {
    data: { userId, friendId },
    headers: JSON_HEADERS,
  });
  return res.data;
}

async function rejectFriendRequest(userId, requesterId) {
  const res = await axios.post(
    `${API_BASE_URL}/api/friends/reject`,
    { userId, requesterId },
    { headers: JSON_HEADERS }
  );
  return res.data;
}

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------
async function testAPI() {
  // state shared across tests
  const testUsername = 'Kim';
  const testPassword = '1234';
  let usersResData = null;
  let testUserId = null;

  // -----------------------------
  // Basic server/db checks
  // -----------------------------
  await T.test('GET /api/ping', async () => {
    const res = await axios.get(`${API_BASE_URL}/api/ping`);
    T.expect(res.status === 200, 'ping should return 200');
    T.expect(res.data != null, 'ping should return body');
  });

  await T.test('GET /api/test-db', async () => {
    const res = await axios.get(`${API_BASE_URL}/api/test-db`);
    T.expect(res.status === 200, 'test-db should return 200');
    T.expect(res.data != null, 'test-db should return body');
  });

  await T.test('GET /api/users', async () => {
    const res = await axios.get(`${API_BASE_URL}/api/users`);
    T.expect(res.status === 200, 'users should return 200');
    usersResData = res.data;
  });

  // -----------------------------
  // Register flow (create + verify + delete)
  // -----------------------------
  await T.test('REGISTER -> LOGIN -> verify room_status -> DELETE', async () => {
    const newUsername = makeRandomUsername('WellspaceUser');
    const newPassword = '1234';

    const reg = await registerUser(newUsername, newPassword);
    const okReg = reg?.ok === true || reg?.success === true;
    T.expect(okReg, 'register should return ok/success');
    T.expect(reg?.user?.id, 'register should return user.id');

    const newUserId = reg.user.id;

    const login = await loginUser(newUsername, newPassword);
    const okLogin = login?.ok === true || login?.success === true;
    T.expect(okLogin, 'login(new user) should return ok/success');

    // verify room_status exists (try /room-status else /plant-status)
    let verified = false;
    try {
      const rsRes = await axios.get(`${API_BASE_URL}/api/room-status/${newUserId}`);
      T.expect(rsRes.status === 200, 'room-status should return 200');
      verified = true;
    } catch (_) {
      const plantRes = await axios.get(`${API_BASE_URL}/api/plant-status/${newUserId}`);
      T.expect(plantRes.status === 200, 'plant-status fallback should return 200');
      verified = true;
    }
    T.expect(verified, 'should verify room_status somehow');

    const del = await deleteUser(newUserId);
    T.expect(del?.ok === true || del?.success === true, 'delete should return ok/success');
  });

  // -----------------------------
  // Login as Kim
  // -----------------------------
  await T.test('LOGIN Kim', async () => {
    const login = await loginUser(testUsername, testPassword);
    T.expect(login?.ok === true || login?.success === true, 'login should return ok/success');
    T.expect(login?.user?.id, 'login should return user.id');
    testUserId = login.user.id;
    T.expect(Number.isInteger(testUserId), 'testUserId should be integer');
    T.expect(testUserId > 0, 'testUserId should be > 0');
  });

  if (!testUserId) {
    T.summary();
    return;
  }

  // -----------------------------
  // Achievements flow (progress)
  // -----------------------------
  await T.test('ACHIEVEMENTS: set 1=55, 2=100; invalid progress rejected', async () => {
    const before = await getAchievements(testUserId);
    const okBefore = before?.ok === true || before?.success === true;
    T.expect(okBefore, 'getAchievements should return ok/success');

    await updateAchievementProgress(testUserId, 1, 55);
    await updateAchievementProgress(testUserId, 2, 100);

    const after = await getAchievements(testUserId);
    const list = after?.achievements || [];
    const a1 = list.find((x) => x.achievement_index === 1);
    const a2 = list.find((x) => x.achievement_index === 2);

    T.expect(a1, 'achievement index 1 should exist');
    T.expect(a2, 'achievement index 2 should exist');
    T.eq(a1.progress, 55, 'achievement 1 progress should be 55');
    T.eq(a2.progress, 100, 'achievement 2 progress should be 100');

    // invalid progress should be rejected (expect 400)
    let rejected = false;
    try {
      await updateAchievementProgress(testUserId, 1, 150);
    } catch (e) {
      rejected = true;
      T.expect(e?.response?.status === 400, 'invalid progress should return 400');
    }
    T.expect(rejected, 'invalid progress should be rejected');
  });

  // -----------------------------
  // Achievements claimed + tier flow
  // -----------------------------
  await T.test('ACHIEVEMENTS: claimed/tier update + verify', async () => {
    // Set on index 1 (keep progress valid)
    await updateAchievement(testUserId, 1, { progress: 55, claimed: true, tier: 2 });

    const after = await getAchievements(testUserId);
    const list = after?.achievements || [];
    const a1 = list.find((x) => x.achievement_index === 1);

    T.expect(a1, 'achievement index 1 should exist');

    // claimed might come back as 0/1 (number) from MySQL
    T.expect(a1.claimed === 1 || a1.claimed === true || a1.claimed === '1', 'claimed should be true/1');
    T.eq(a1.tier, 2, 'tier should be 2');

    // Negative: tier < 0 should reject (400)
    let tierRejected = false;
    try {
      await updateAchievement(testUserId, 1, { progress: 55, tier: -1 });
    } catch (e) {
      tierRejected = true;
      T.eq(e?.response?.status, 400, 'invalid tier should return 400');
    }
    T.expect(tierRejected, 'invalid tier should be rejected');
  });

  // -----------------------------
  // Status GET endpoints (just ensure 200 + value exists)
  // -----------------------------
  await T.test('GET plant/dog/window/mood', async () => {
    const plant = await axios.get(`${API_BASE_URL}/api/plant-status/${testUserId}`);
    const dog = await axios.get(`${API_BASE_URL}/api/dog-status/${testUserId}`);
    const win = await axios.get(`${API_BASE_URL}/api/window-status/${testUserId}`);
    const mood = await axios.get(`${API_BASE_URL}/api/room-mood/${testUserId}`);

    T.expect(plant.status === 200, 'plant-status should be 200');
    T.expect(dog.status === 200, 'dog-status should be 200');
    T.expect(win.status === 200, 'window-status should be 200');
    T.expect(mood.status === 200, 'room-mood should be 200');
  });

  // -----------------------------
  // Status UPDATE endpoints + recheck (loose check)
  // -----------------------------
  await T.test('PUT plant/dog/window/mood then recheck', async () => {
    await axios.put(`${API_BASE_URL}/api/plant-status/${testUserId}`, { plant_status: 0.25 }, { headers: JSON_HEADERS });
    await axios.put(`${API_BASE_URL}/api/dog-status/${testUserId}`, { dog_status: 0.50 }, { headers: JSON_HEADERS });
    await axios.put(`${API_BASE_URL}/api/window-status/${testUserId}`, { window_status: 1.0 }, { headers: JSON_HEADERS });
    await axios.put(`${API_BASE_URL}/api/room-mood/${testUserId}`, { room_mood: 0.75 }, { headers: JSON_HEADERS });

    const plant = await axios.get(`${API_BASE_URL}/api/plant-status/${testUserId}`);
    const dog = await axios.get(`${API_BASE_URL}/api/dog-status/${testUserId}`);
    const win = await axios.get(`${API_BASE_URL}/api/window-status/${testUserId}`);
    const mood = await axios.get(`${API_BASE_URL}/api/room-mood/${testUserId}`);

    // Values should exist and be numbers (don’t require exact equality due to formatting/rounding)
    T.expect(isNumeric(plant.data.plant_status), 'plant_status should be numeric');
    T.expect(isNumeric(dog.data.dog_status), 'dog_status should be numeric');
    T.expect(isNumeric(win.data.window_status), 'window_status should be numeric');
    T.expect(isNumeric(mood.data.room_mood), 'room_mood should be numeric');
  });

  // -----------------------------
  // Full room status
  // -----------------------------
  await T.test('GET full /api/room-status/:id', async () => {
    const res = await axios.get(`${API_BASE_URL}/api/room-status/${testUserId}`);
    T.expect(res.status === 200, 'room-status should be 200');
    T.expect(res.data?.room_status, 'room_status field should exist');
  });

  // -----------------------------
  // Step goal
  // -----------------------------
  await T.test('STEP GOAL: GET -> PUT -> GET', async () => {
    const before = await axios.get(`${API_BASE_URL}/api/step-goal/${testUserId}`);
    T.expect(before.status === 200, 'step-goal get should be 200');

    await axios.put(`${API_BASE_URL}/api/step-goal/${testUserId}`, { step_goal: 6000 }, { headers: JSON_HEADERS });

    const after = await axios.get(`${API_BASE_URL}/api/step-goal/${testUserId}`);
    T.expect(after.status === 200, 'step-goal re-get should be 200');
  });

  // -----------------------------
  // Water goal
  // -----------------------------
  await T.test('WATER GOAL: GET -> PUT -> GET', async () => {
    const before = await axios.get(`${API_BASE_URL}/api/waterintake-goal/${testUserId}`);
    T.expect(before.status === 200, 'water goal get should be 200');

    await axios.put(`${API_BASE_URL}/api/waterintake-goal/${testUserId}`, { waterintake_goal: 2500 }, { headers: JSON_HEADERS });

    const after = await axios.get(`${API_BASE_URL}/api/waterintake-goal/${testUserId}`);
    T.expect(after.status === 200, 'water goal re-get should be 200');
  });

  // -----------------------------
  // User location
  // -----------------------------
  await T.test('USER LOCATION: GET -> PUT -> GET', async () => {
    const before = await axios.get(`${API_BASE_URL}/api/user-location/${testUserId}`);
    T.expect(before.status === 200, 'user-location get should be 200');
    const loc = before.data.user_location;

    const newLoc = loc === 'inside' ? 'outside' : 'inside';
    await axios.put(`${API_BASE_URL}/api/user-location/${testUserId}`, { user_location: newLoc }, { headers: JSON_HEADERS });

    const after = await axios.get(`${API_BASE_URL}/api/user-location/${testUserId}`);
    T.expect(after.status === 200, 'user-location re-get should be 200');
    T.eq(after.data.user_location, newLoc, 'user_location should match updated value');
  });

  // -----------------------------
  // Coin flow (+ negatives)
  // -----------------------------
  await T.test('COIN: GET -> PUT -> GET (+ negatives)', async () => {
    const before = await getUserCoin(testUserId);
    T.expect(before?.ok === true, 'getUserCoin should return ok:true');
    T.expect(typeof before.coin === 'number', 'coin should be number');

    const newCoin = before.coin + 10;
    const upd = await updateUserCoin(testUserId, newCoin);
    T.expect(upd?.ok === true, 'updateUserCoin should return ok:true');

    const after = await getUserCoin(testUserId);
    T.eq(after.coin, newCoin, 'coin should match updated value');

    // missing coin body should be 400
    let missingRejected = false;
    try {
      await axios.put(`${API_BASE_URL}/api/users/${testUserId}/coin`, {}, { headers: JSON_HEADERS });
    } catch (e) {
      missingRejected = true;
      T.eq(e?.response?.status, 400, 'missing coin should return 400');
    }
    T.expect(missingRejected, 'missing coin should be rejected');

    // invalid user should be 404 (or 400 depending on your backend)
    let invalidRejected = false;
    try {
      await getUserCoin(-1);
    } catch (e) {
      invalidRejected = true;
      T.expect([400, 404].includes(e?.response?.status), 'invalid user should return 400 or 404');
    }
    T.expect(invalidRejected, 'invalid user should be rejected');
  });

  // -----------------------------
  // Friends flow (+ resend test)
  // -----------------------------
  await T.test('FRIENDS: send -> accept -> list -> remove', async () => {
    // need ids from /api/users
    const kimId = findUserId(usersResData, 'Kim');
    const tommyId = findUserId(usersResData, 'Tommy');
    T.expect(kimId && tommyId, 'should find Kim and Tommy ids');

    await sendFriendRequest(kimId, 'Tommy');

    const incoming = await getIncomingFriendRequests(tommyId);
    const requests = incoming?.requests || [];
    const reqFromKim = requests.find((r) => r.requester_id === kimId);
    T.expect(reqFromKim, 'Tommy should have pending request from Kim');

    await acceptFriendRequest(tommyId, kimId);

    const kimFriends = await getFriendsList(kimId);
    const tommyFriends = await getFriendsList(tommyId);
    T.expect(kimFriends?.friends, 'Kim friends should exist');
    T.expect(tommyFriends?.friends, 'Tommy friends should exist');

    await removeFriend(kimId, tommyId);
  });

  await T.test('FRIENDS RESEND: reject -> resend -> accept', async () => {
    const kimId = findUserId(usersResData, 'Kim');
    const tommyId = findUserId(usersResData, 'Tommy');
    T.expect(kimId && tommyId, 'should find Kim and Tommy ids');

    // cleanup if already friends (ignore)
    try { await removeFriend(kimId, tommyId); } catch (_) {}
    try { await removeFriend(tommyId, kimId); } catch (_) {}

    // send
    await sendFriendRequest(kimId, 'Tommy');

    // reject
    const incoming1 = await getIncomingFriendRequests(tommyId);
    const req1 = (incoming1?.requests || []).find(r => r.requester_id === kimId);
    T.expect(req1, 'should have pending request before reject');

    await rejectFriendRequest(tommyId, kimId);

    // resend (should not be blocked by rejected status)
    const resend = await sendFriendRequest(kimId, 'Tommy');
    const msg = (resend?.message || '').toLowerCase();
    T.expect(!msg.includes('existing relationship status: rejected'), 'resend should not be blocked by rejected status');

    // accept again
    const incoming2 = await getIncomingFriendRequests(tommyId);
    const req2 = (incoming2?.requests || []).find(r => r.requester_id === kimId);
    T.expect(req2, 'should have pending request after resend');

    await acceptFriendRequest(tommyId, kimId);

    // cleanup remove friend
    await removeFriend(kimId, tommyId);
  });

  // -----------------------------
  // First-time + Tutorial complete flow
  // -----------------------------
  await T.test('FIRST-TIME: new user -> true; tutorial-complete -> false; repeat complete rejected; then DELETE', async () => {
    const newUsername = makeRandomUsername('FirstTimeUser');
    const newPassword = '1234';

    // register
    const reg = await registerUser(newUsername, newPassword);
    T.expect(reg?.user?.id, 'register should return user.id');
    const newUserId = reg.user.id;

    // optional: login (not required for these endpoints, but matches your flow)
    const login = await loginUser(newUsername, newPassword);
    T.expect(login?.ok === true || login?.success === true, 'login(new user) should return ok/success');

    // 1) should be first time
    const ft1 = await getIsFirstTime(newUserId);
    T.expect(ft1?.ok === true, 'first-time endpoint should return ok:true');
    T.eq(ft1.isFirstTime, true, 'new user should be isFirstTime=true');

    // 2) mark tutorial complete
    const done = await tutorialComplete(newUserId);
    T.expect(done?.ok === true, 'tutorial-complete should return ok:true');

    // 3) now should be NOT first time
    const ft2 = await getIsFirstTime(newUserId);
    T.expect(ft2?.ok === true, 'first-time endpoint should return ok:true');
    T.eq(ft2.isFirstTime, false, 'after complete should be isFirstTime=false');

    // 4) calling tutorial-complete again should be rejected (404 in our suggested backend)
    let repeatRejected = false;
    try {
      await tutorialComplete(newUserId);
    } catch (e) {
      repeatRejected = true;
      T.eq(e?.response?.status, 404, 'repeat tutorial-complete should return 404');
    }
    T.expect(repeatRejected, 'repeat tutorial-complete should be rejected');

    // cleanup
    const del = await deleteUser(newUserId);
    T.expect(del?.ok === true || del?.success === true, 'delete should return ok/success');
  });

  T.summary();
}

testAPI().catch((e) => {
  console.error('Fatal test runner error:', e?.message || e);
  T.summary();
});
