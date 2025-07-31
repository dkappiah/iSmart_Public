# iSmart Bank - Digital Wallet System  

## Table of Contents  
1. [Project Overview](#project-overview)  
2. [Core Features](#core-features)  
   - [User Authentication](#1-user-authentication)  
   - [Wallet Dashboard](#2-wallet-dashboard)  
   - [Add Funds](#3-add-funds-top-up)  
   - [Transfer Funds](#4-transfer-funds)  
   - [Transaction History](#5-transaction-history)  
3. [Technical Stack](#technical-stack)  
4. [Setup & Installation](#setup--installation)  
5. [Project Structure](#project-structure)  
6. [Key Code Snippets](#key-code-snippets)  
7. [License](#license)  
8. [Future Improvements](#future-improvements) 
---

## Project Overview  

iSmart Bank is a lightweight digital wallet system designed to provide basic banking functionalities through a web interface. The system allows registered users to manage their funds, perform transactions, and view their financial activity history. Built using PHP and MySQL for backend operations with HTML/CSS/JavaScript for the frontend, this project serves as a practical implementation of core banking features in a secure, session-based environment.  

---

## Core Features  

### 1. User Authentication  
- **Registration**: New users can create accounts by providing essential details (Account Number, Name, Email, Password).  
- **Login/Logout**: Implements secure session management with server-side validation.  


### 2. Wallet Dashboard  
- **Balance Overview**: Displays the current available balance prominently.  
- **Financial Summary**: Shows total income (credits) and expenses (debits) for quick reference.  
- **Recent Activity**: Lists the recent transactions with basic details.  

### 3. Add Funds (Top-Up)  
- **Balance Update**: Simulates adding funds by directly incrementing the user's balance.  
- **Transaction Recording**: Creates a log entry for each top-up operation with timestamp and amount.  

### 4. Transfer Funds  
- **Peer Transfers**: Enables sending money to other registered users.  
- **Validation Checks**:  
  - Verifies sufficient sender balance  
  - Confirms recipient account exists  
  - Prevents self-transfers  
- **Fee Structure**: Implements tiered transfer fees (e.g., 0.50 for amounts ≤100, 1.00 for 101-500, etc.).  

### 5. Transaction History  
- **Comprehensive Logs**:  
  - Transaction type (Credit/Debit) with visual indicators  
  - Exact amount transferred  
  - Date and time of transaction  
  - Additional remarks/notes  
- **Chronological Order**: Sorted by most recent first.  

---

## Technical Stack  
Backend -         PHP   , MySQL
Frontend    -      HTML, CSS  , JavaScript
Authentication -  Session 
Database  -       MySQL


**Database Schema**:  
- `balance`: Stores account balances  
- `credentials`: Manages login credentials  
- `transactions`: Records all financial activity  
- `userinfo`: Contains user profile data  

---

## Setup & Installation  

### Requirements  
- PHP  
- MySQL  database  
- Apache web server  (XAMP)

### Deployment Steps  
1. **Database Setup**:  
   - Import the provided `bms.sql` file to initialize database structure  
   - Configure credentials in `configs/db.php`  

2. **Application Launch**:  
   ```bash
   git clone [repository-url]
   cd iSmart-Bank
   php -S localhost:8000
   ```
   Access the application at: `http://localhost:8000/pages/index.php`  

3. **Default Configuration**:  
   - Initial account balance: GHc 100 (modifiable in registration logic)  
   - Test accounts are created during database import  

---



---

## Key Code Snippets  

### Transfer Validation (bal_transfer.php)  
```php
// Verify sufficient funds
if ($sender_balance < ($amount + $fee)) {
    header("Location: ../transfer.php?msg=Insufficient Funds");
    exit;
}

// Execute transfer
$update_sender = "UPDATE balance SET Balance = Balance - $amount - $fee WHERE AccNo = '$sender_accNo'";
mysqli_query($conn, $update_sender);
```

### Transaction Recording  
```php
$log_transaction = "INSERT INTO transactions 
                   (Sender, Receiver, Amount, Remarks, DateTime) 
                   VALUES 
                   ('$sender', '$receiver', '$amount', '$remarks', NOW())";
```





A video  on how the web app is used will be added soon