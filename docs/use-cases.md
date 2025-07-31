# Wallet Application User Stories

👤 **Primary Actor:** Registered User  
Users must sign up and log in to access wallet features.

## 📄 User Stories (Simple Format)

### 1. 🔐 User Registration
As a new user, I want to register with a username, email, and password so that I can create an account and use the wallet.

**Acceptance Criteria:**
* Input fields: username, email, password
* Validations: unique email & username, password strength
* Account stored in the database
* Redirect to login page on success

### 2. 🔓 User Login
As a returning user, I want to log in with my email and password so I can access my wallet dashboard.

**Acceptance Criteria:**
* Input: email, password
* Check credentials against DB
* Redirect to dashboard or show error

### 3. 💼 View Wallet Dashboard
As a logged-in user, I want to see my current wallet balance and a quick link to all wallet features.

**Acceptance Criteria:**
* Display current balance
* Show nav links: Add Funds, Transfer, Transaction History

### 4. ➕ Add Funds
As a user, I want to simulate adding funds to my wallet so I can increase my balance.

**Acceptance Criteria:**
* Input: amount
* Update balance in DB
* Show success confirmation

### 5. 🔁 Transfer Funds
As a user, I want to transfer funds to another registered user using their email or username.

**Acceptance Criteria:**
* Input: recipient username/email, amount
* Check:
  * recipient exists
  * sender has sufficient balance
* Subtract from sender, add to receiver
* Record in transaction history

### 6. 📜 View Transaction History
As a user, I want to see a history of all my transactions including date, amount, and status.

**Acceptance Criteria:**
* Fetch from DB all transactions related to the user
* Show: Date, Type (Add/Transfer), Amount, Status

### 🔁 (Optional) Password Recovery (Mocked)
As a user, I want to recover my password in case I forget it.

**Acceptance Criteria:**
* Input: email
* Show mock message: "Password reset link sent to your email"
* Log this to console (no real email logic needed)