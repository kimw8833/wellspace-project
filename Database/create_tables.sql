DROP DATABASE IF EXISTS wellspacedb;
CREATE DATABASE IF NOT EXISTS wellspacedb;

USE wellspacedb;

DROP TABLE IF EXISTS users;

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
