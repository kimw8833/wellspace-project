DROP DATABASE IF EXISTS wellspacedb;
CREATE DATABASE IF NOT EXISTS wellspacedb;

USE wellspacedb;

DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS room_status;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

INSERT INTO users (username, password) VALUES
('Kim', '1234'),
('Martin', '1234'),
('Tommy', '1234'),
('Benjamin', '1234');

CREATE TABLE room_status (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,

  plant_status TINYINT NOT NULL DEFAULT 0,   -- 0=dead,1=sad,2=happy
  dog_status TINYINT NOT NULL DEFAULT 0,     -- 0=restless,1=neutral,2=happy
  window_status TINYINT NOT NULL DEFAULT 0,  -- 0=closed,1=open
  room_mood TINYINT NOT NULL DEFAULT 0,      -- 0=chaos,1=cozy,2=calm

  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
              ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- create default status for each user
INSERT INTO room_status (user_id)
SELECT id FROM users;

ALTER TABLE room_status
  ADD COLUMN last_plant_care TIMESTAMP NULL,
  ADD COLUMN last_dog_play TIMESTAMP NULL,
  ADD COLUMN last_window_open TIMESTAMP NULL;