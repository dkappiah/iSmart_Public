<?php
session_start();
require_once 'inc/db_connect.php';

//Initializing arrays to hold error messages and success status
$errors = [];
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $email    = trim($_POST['email']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];

    //Validation checks for user inputs
    if (empty($username) || empty($email) || empty($password)) {
        $errors[] = "All fields are required.";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Invalid email format.";
    }

    if ($password !== $confirm_password) {
        $errors[] = "Passwords do not match.";
    }
    
    if (empty($errors)) {
        //Checking if username or email already exists
        $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
        $stmt->execute([$username, $email]);

        if ($stmt->fetch()) {
            $_SESSION['alert_type'] = 'error';
            $_SESSION['alert_message'] = 'Username or email already exists.';
        } else {
            //Hash the password and insert the new user's info into the database
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
            $stmt->execute([$username, $email, $hashedPassword]);

            $_SESSION['alert_type'] = 'success';
            $_SESSION['alert_message'] = "Registration successful! You can now <a href='login.php'>log in</a>.";
        }

        //Redirect to reload the page and trigger the sweet alert
        header("Location: register.php");
        exit;
    } else {
        $_SESSION['alert_type'] = 'error';
        $_SESSION['alert_message'] = implode('<br>', $errors);

        header("Location: register.php");
        exit;
    }
}
?>

<?php 
//Hiding the nav bar
$hideNav = true;
include 'inc/header.php'; 
?>

<!--Registration form-->
<div class="form-wrapper">
    <form method="POST">
        <label>Username</label>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-user"></i></span>
            <input type="text" name="username" placeholder="Enter username">
        </div><br>

        <label>Email</label>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-envelope"></i></span>
            <input type="email" name="email" placeholder="Enter email">
        </div><br>

        <label>Password</label>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-key"></i></span>
            <input type="password" name="password" placeholder="Enter password">
        </div><br>

        <label>Confirm Password</label>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-lock"></i></span>
            <input type="password" name="confirm_password" placeholder="Confirm password">
        </div><br>

        <button type="submit">Register</button>
        <p>Already have an account? <a href="login.php">Login here</a></p>
    </form>
</div>

<!--SweetAlert popup message (only shown if session alert is set)-->
<?php if (isset($_SESSION['alert_type']) && isset($_SESSION['alert_message'])): ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
    //Triggers a SweetAlert popup using session values passed from PHP
    Swal.fire({
        icon: <?= json_encode($_SESSION['alert_type']); ?>,
        title: <?= json_encode($_SESSION['alert_type'] === 'success' ? 'Success!' : 'Error'); ?>,
        html: <?= json_encode($_SESSION['alert_message']); ?>,
        confirmButtonColor: '#3085d6'
    });
});
</script>
<?php 
//Clearing the alert from the session so it doesn't show on page refresh
unset($_SESSION['alert_type']);
unset($_SESSION['alert_message']);
endif;
?>
