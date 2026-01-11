# Wellspace Backend

Backend server for the **Wellspace** project  
Built with **Node.js + Express + MySQL**

---

## Project Structure

```
backend/
├─ server.js                # Main server entry
├─ server_tests.js          # API test runner
│
├─ db/
│  └─ pool.js               # MySQL connection pool
│
└─ routes/
   ├─ achievements.routes.js
   ├─ auth.routes.js
   ├─ coin.routes.js
   ├─ friends.routes.js
   ├─ goals.routes.js
   ├─ misc.routes.js
   └─ room.routes.js
```

---

## Running the Server

Start the backend server:

```bash
node server.js
```

---

## Running API Tests

> **Important**  
> The server **must be running** before executing tests.

### Run all tests (default)

```bash
node server_tests.js
```

---

### Run a specific test suite

```bash
TEST_SUITE=core node server_tests.js
TEST_SUITE=achievements node server_tests.js
TEST_SUITE=features node server_tests.js
TEST_SUITE=social node server_tests.js
TEST_SUITE=onboarding node server_tests.js
TEST_SUITE=all node server_tests.js
```

---

## Available Test Suites

| Suite name     | What it tests |
|----------------|--------------|
| `core`         | Server health, DB, register, login |
| `achievements`| Achievement progress, claim, tiers |
| `features`    | Room, goals, location, coin |
| `social`      | Friends system |
| `onboarding`  | First-time user & tutorial flow |
| `all`         | All tests |

---

## Quick Start

```bash
# Terminal 1
node server.js

# Terminal 2
TEST_SUITE=onboarding node server_tests.js
```