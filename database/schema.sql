-- USERS TABLE
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- store hashed password
    balance DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TRANSACTIONS TABLE
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                      -- the person who owns the transaction
    type ENUM('add', 'transfer') NOT NULL,     -- transaction type
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'success',      -- success, failed, etc.
    related_user_id INT,                       -- receiver/sender for transfer
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (related_user_id) REFERENCES users(id)
);
 