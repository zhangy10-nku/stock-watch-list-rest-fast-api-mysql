-- Create the main database
CREATE DATABASE IF NOT EXISTS stockwatchlist;
USE stockwatchlist;

-- Create stocks table (will also be created by SQLAlchemy, but this ensures it exists)
CREATE TABLE IF NOT EXISTS stocks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  symbol VARCHAR(10) NOT NULL,
  name VARCHAR(255) NOT NULL,
  price FLOAT,
  user_id VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_symbol (symbol),
  INDEX idx_user_id (user_id),
  UNIQUE KEY unique_user_symbol (user_id, symbol)
);

-- Grant privileges
GRANT ALL PRIVILEGES ON stockwatchlist.* TO 'stockuser'@'%';
FLUSH PRIVILEGES;
