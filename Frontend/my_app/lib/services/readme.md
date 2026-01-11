# Wellspace Frontend – API Service & Test Runner

This README describes how to use the **ApiService (Flutter/Dart)** and the accompanying  
**Mini Test Runner** used to validate the Wellspace backend API end-to-end.

It is intended for frontend developers and for quick regression testing during development.

---

## Project Structure

```
lib/
 ├─ services/
 │   └─ api_service.dart        # Centralized API client
     └─ api_service_test.dart   # Mini test runner (PASS / FAIL)
     
```

---

## Base URL

```dart
final String baseUrl =
  'https://paragogically-unlegible-grazyna.ngrok-free.dev';
```

### Notes
- The backend is exposed via **ngrok**
- All requests must include this header:
  ```
  ngrok-skip-browser-warning: true
  ```

---

## Authentication APIs

### Register
```
POST /api/register
```

```dart
api.register(username, password)
```

Expected response:
```json
{
  "ok": true,
  "user": { "id": 1, "username": "Kim" }
}
```

---

### Login
```
POST /api/login
```

```dart
api.login(username, password)
```

---

### Delete User
```
DELETE /api/users/:userId
```

```dart
api.deleteUser(userId)
```

---

## First-Time User & Tutorial Flow

### Check First-Time Status
```
GET /api/users/:userId/first-time
```

```dart
api.isFirstTimeUser(userId)
```

Response:
```json
{ "ok": true, "isFirstTime": true }
```

---

### Mark Tutorial Complete
```
POST /api/users/:userId/tutorial-complete
```

```dart
api.markTutorialComplete(userId)
```

Behavior:
- First call succeeds
- Subsequent calls fail (tutorial already completed)

---

## Achievements APIs

### Get Achievements
```
GET /api/achievements/:userId
```

```dart
api.getAchievements(userId)
```

---

### Update Progress
```
PUT /api/achievements/:userId/:index/progress
```

```dart
api.updateAchievementProgress(userId, index, progress)
```

---

### Update Claimed State
```
PUT /api/achievements/:userId/:index/claimed
```

```dart
api.updateAchievementClaimed(userId, index, 0 or 1)
```

---

### Update Tier
```
PUT /api/achievements/:userId/:index/tier
```

```dart
api.updateAchievementTier(userId, index, tier)
```

---

## Room & Status APIs

| Feature     | Endpoint |
|------------|----------|
| Plant      | `/api/plant-status/:userId` |
| Dog        | `/api/dog-status/:userId` |
| Window     | `/api/window-status/:userId` |
| Room Mood  | `/api/room-mood/:userId` |
| Full Room  | `/api/room-status/:userId` |

Example:
```dart
api.getPlantStatus(userId);
api.updatePlantStatus(userId, 0.5);
```

---

## Goals APIs

### Step Goal
```
GET /api/step-goal/:userId
PUT /api/step-goal/:userId
```

```dart
api.getStepGoal(userId);
api.updateStepGoal(userId, newGoal);
```

---

### Water Intake Goal
```
GET /api/waterintake-goal/:userId
PUT /api/waterintake-goal/:userId
```

---

## User Location

```
GET /api/user-location/:userId
PUT /api/user-location/:userId
```

```dart
api.getUserLocation(userId);
api.updateUserLocation(userId, "inside" | "outside");
```

---

## Coins

```
GET /api/users/:userId/coin
PUT /api/users/:userId/coin
```

```dart
api.getUserCoin(userId);
api.updateUserCoin(userId, newValue);
```

---

## Friends System

### Send Friend Request
```
POST /api/friends/add
```

```dart
api.sendFriendRequest(userId, friendUsername);
```

---

### Incoming Requests
```
GET /api/friend-requests/:userId
```

---

### Accept / Reject Request
```
POST /api/friends/accept
POST /api/friends/reject
```

---

### Get Friends List
```
GET /api/friends/:userId
```

---

### Remove Friend
```
DELETE /api/friends
```

---

## Mini Test Runner

The file `api_service_test.dart` runs automated API checks without external test libraries.

### Example Output
```
PASS: LOGIN Kim
PASS: ACHIEVEMENTS update
PASS: COIN update
```

### Summary
```
==== TEST SUMMARY ====
Passed: 18
Failed: 0
=====================
```

---

## Covered Test Flows

- Register → Login → Delete
- First-time user & tutorial completion
- Achievements (progress / claimed / tier)
- Room and status updates
- Step & water goals
- User location
- Coins
- Friends flow (send → accept → remove)

---

## How to Run Tests

```bash
dart run api_service_test.dart
```

Requirements:
- Backend server running
- ngrok tunnel active

---

## Notes

- Tests create **temporary users** and clean them up automatically
- Suitable for smoke tests and backend verification
- Dependency-free (no `test` package)

---