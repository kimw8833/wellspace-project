-- Database/create_tables.sql
-- SQL script to create the wellspacedb database and its tables

DROP DATABASE IF EXISTS wellspacedb;
CREATE DATABASE IF NOT EXISTS wellspacedb;

USE wellspacedb;

-- Drop the tables acc. to foreign key's dependency order
DROP TABLE IF EXISTS daily_steps;
DROP TABLE IF EXISTS room_status;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS friendships;

-- ---------------------------
-- 1) Users table
-- ---------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username          VARCHAR(50)  NOT NULL UNIQUE,
    password          VARCHAR(255) NOT NULL,

    step_goal         INT NOT NULL DEFAULT 4000,       -- user’s daily step goal
    waterintake_goal  INT NOT NULL DEFAULT 2000,       -- daily water intake goal (ml)
    coin              INT NOT NULL DEFAULT 0,          -- user’s current coin balance
    user_location     VARCHAR(20) NOT NULL DEFAULT 'inside'  -- inside/outside
);

INSERT INTO users (username, password, step_goal, waterintake_goal, coin, user_location) VALUES
    ('Benjamin', '1234', 4000, 2000, 0, 'inside'),
    ('Kim',      '1234', 4000, 2000, 0, 'inside'),
    ('Martin',   '1234', 4000, 2000, 0, 'inside'),
    ('Tommy',    '1234', 4000, 2000, 0, 'inside');

-- ---------------------------
-- 2) Room Status table (1:1 with users → use user_id as PK)
-- ---------------------------
CREATE TABLE room_status (
  user_id INT NOT NULL,

  plant_status    DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  dog_status      DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  window_status   DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  room_mood       DECIMAL(3,2) NOT NULL DEFAULT 0.00,

  -- update timestamps (vid ändringen av värden)
  last_plant_update   TIMESTAMP NULL,
  last_dog_update     TIMESTAMP NULL,
  last_window_update  TIMESTAMP NULL,
  last_room_update    TIMESTAMP NULL, 

  -- read timestamps (vid hämntning av värden)
  last_plant_read   TIMESTAMP NULL,
  last_dog_read     TIMESTAMP NULL,
  last_window_read  TIMESTAMP NULL,
  last_room_read    TIMESTAMP NULL,

  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
             ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id),

  CONSTRAINT fk_room_status_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
);


-- create default 1 room_status row per user
INSERT INTO room_status (user_id)
SELECT id FROM users;


-- ---------------------------------------------------
-- 3) CREATE TABLE: daily_steps (use composite PK: user_id + date)
-- ---------------------------------------------------
CREATE TABLE daily_steps (
    user_id INT  NOT NULL,
    date    DATE NOT NULL,              -- date for the steps record
    steps   INT  NOT NULL DEFAULT 0,    -- total steps for that date

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, date),        -- 1 user 1 row per date

    CONSTRAINT fk_daily_steps_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
);


-- ---------------------------------------------------
-- 4) Friendships table (friend requests + friends)
-- ---------------------------------------------------
CREATE TABLE friendships (
    id INT AUTO_INCREMENT PRIMARY KEY,

    requester_id INT NOT NULL,   -- user who sent the friend request
    receiver_id  INT NOT NULL,   -- user who received the friend request

    status ENUM('pending', 'accepted', 'rejected', 'blocked')
           NOT NULL DEFAULT 'pending',

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
               ON UPDATE CURRENT_TIMESTAMP,

    -- cannot send friend request to oneself
    CONSTRAINT chk_not_self_friend
        CHECK (requester_id <> receiver_id),

    -- one pair of users can have only one friendship record
    CONSTRAINT uc_friend_pair
        UNIQUE (requester_id, receiver_id),

    CONSTRAINT fk_friendships_requester
        FOREIGN KEY (requester_id) REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_friendships_receiver
        FOREIGN KEY (receiver_id)  REFERENCES users(id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------
-- 5) Achievements progress table (simple index + progress)
-- ---------------------------------------------------
DROP TABLE IF EXISTS user_achievements;

CREATE TABLE user_achievements (
    user_id INT NOT NULL,
    achievement_index INT NOT NULL,        -- 1,2,3,... (frontend maps meaning)
    progress TINYINT UNSIGNED NOT NULL DEFAULT 0,  -- 0..100
    claimed TINYINT(1) NOT NULL DEFAULT 0, -- 0=false, 1=true
    tier INT NOT NULL DEFAULT 0,
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, achievement_index),

    CONSTRAINT fk_user_achievements_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_progress_range
        CHECK (progress <= 100)
);

-- Create default achievement rows for each user
INSERT INTO user_achievements (user_id, achievement_index, progress)
SELECT u.id, a.achievement_index, 0
FROM users u
JOIN (
  SELECT 1 AS achievement_index
  UNION ALL SELECT 2
  UNION ALL SELECT 3
) a;