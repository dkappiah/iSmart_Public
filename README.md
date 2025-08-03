# iSmart_Public
# DigiPay - Digital Wallet Web App

DigiPay is a simple PHP-based digital wallet web application.  
Users can register, log in, add funds, transfer money, view transactions, change passwords, and receive email notifications.  
The project also supports dark mode and SweetAlert notifications for an enhanced user experience.

## Features

- User registration and login
- Secure password hashing and session management
- Add funds and transfer money between users
- Transaction history with previews on the dashboard
- Change password functionality
- Email notifications on transfer (using PHPMailer)
- SweetAlert popups for user-friendly alerts
- Dark mode toggle for better accessibility
- Responsive design for desktop & mobile

## Technologies Used

- PHP (Core backend)
- MySQL (Database)
- PDO (Database interaction)
- PHPMailer (Email sending)
- SweetAlert2 (Popup alerts)
- HTML/CSS + Font Awesome (Frontend)

## Summary of Design and Technology Choices

DigiPay was designed with simplicity, responsiveness, and modularity in mind. The following design and technology decisions were made:

- **Frontend:** HTML5, CSS3, and vanilla JavaScript for core interactivity. Font Awesome is used for icons, and SweetAlert2 for user-friendly alerts.
- **Backend:** PHP with PDO for secure database interactions and session management.
- **Database:** MySQL (accessed via PDO) to handle users, balances, and transactions.
- **Email Notifications:** PHPMailer was used to simulate and optionally support real-time email notifications.
- **Security Measures:** Passwords are securely hashed using `password_hash()` and verified with `password_verify()`. Input validation and session checks are consistently applied.

## Project Structure

```
digital-wallet/
│
├── assets/                → Images and logos
├── inc/                   → Reusable PHP files (db_connect.php, header.php, send_email.php)
├── phpmailer/             → PHPMailer library files
├── scripts/               → JavaScript files (script.js)
├── styles/                → CSS files (style.css)
├── add_funds.php          → Add funds page
├── change_password.php    → Change password page
├── dashboard.php          → User dashboard
├── login.php              → User login page
├── logout.php             → Logout script
├── register.php           → User registration page
├── transactions.php       → View transactions
├── transfer.php           → Transfer money
├── forgot_password.php      → Request password reset
├── reset_password.php     → Reset password with token
└── README.md              → Project documentation
```

---

## 💻 Installation & Setup

Step 1:
**Clone or download the project**
```bash
git clone https://github.com/dkappiah/iSmart_Public/tree/afif_jawhary
```

Step 2:
**Set up your local server**  
Use XAMPP, WAMP, or any PHP server.  
Place the folder inside the `htdocs` directory (`C:/xampp/htdocs` if using XAMPP).

Step 3:
**Import the database**
- Open **phpMyAdmin**.
- Create a new database (e.g. `digital_wallet`).
- Import the provided SQL file (`digital_wallet.sql`).

Step 4:**Configure database connection**
- Open `inc/db_connect.php`.
- Update the credentials:
```php
$host = 'localhost';
$db   = 'digital_wallet';
$user = 'root';
$pass = '';
```

Step 5:
**(Optional) Setup email**
- Use Gmail SMTP or any SMTP service.
- Create an App Password if using Gmail.
- Open `inc/send_email.php` and configure:
```php
$mail->Username = 'your_email@gmail.com';
$mail->Password = 'your_app_password';
$mail->setFrom('your_email@gmail.com', 'DigiPay');
```

6️⃣ **Start the server**
Open your browser and visit:
```
http://localhost/digital-wallet/
```

## 🚀 Future Improvements

- Allowing users to reverse recent transactions (or at least sending requests to admins to reverse a transaction)
- Admin dashboard for user oversight
- Profile page for added customization
- Two-factor authentication
- REST API for mobile integration

---

This project uses:
- [PHPMailer](https://github.com/PHPMailer/PHPMailer)
- [SweetAlert2](https://sweetalert2.github.io/)
- [Font Awesome](https://fontawesome.com/)

---
