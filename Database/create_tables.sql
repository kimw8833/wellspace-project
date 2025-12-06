DROP DATABASE IF EXISTS wellspacedb;
CREATE DATABASE IF NOT EXISTS wellspacedb;

USE wellspacedb;

-- Drop the tables acc. to foreign key's dependency order
DROP TABLE IF EXISTS daily_steps;
DROP TABLE IF EXISTS room_status;
DROP TABLE IF EXISTS users;


-- ---------------------------
-- 1) Users table
-- ---------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username          VARCHAR(50)  NOT NULL UNIQUE,
    password          VARCHAR(255) NOT NULL,

    step_goal         INT NOT NULL DEFAULT 4000,       -- user’s daily step goal
    waterintake_goal  INT NOT NULL DEFAULT 2000,       -- daily water intake goal (ml)
    user_location     VARCHAR(20) NOT NULL DEFAULT 'inside'  -- inside/outside
);

INSERT INTO users (username, password, step_goal, waterintake_goal, user_location) VALUES
    ('Benjamin', '1234', 4000, 2000, 'inside'),
    ('Kim',      '1234', 4000, 2000, 'inside'),
    ('Martin',   '1234', 4000, 2000, 'inside'),
    ('Tommy',    '1234', 4000, 2000, 'inside');
    
-- ---------------------------
-- 2) Room Status table (1:1 with users → use user_id as PK)
-- ---------------------------
CREATE TABLE room_status (
  user_id INT NOT NULL,

    plant_status    DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    dog_status      DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    window_status   DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    room_mood       DECIMAL(3,2) NOT NULL DEFAULT 0.00,


  last_plant_update TIMESTAMP NULL,
  last_dog_update   TIMESTAMP NULL,
  last_room_update  TIMESTAMP NULL,

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