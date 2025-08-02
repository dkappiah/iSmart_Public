<?php
session_start();
require_once 'inc/db_connect.php';

//Initializing an array to collect any errors
$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email']);
    $password = $_POST['password'];

    //Validation checks for user inputs
    if (empty($email) || empty($password)) {
        $errors[] = "Both fields are required.";
    } else {
        //Fetch the user by email
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        //Checking if the user exists and the password entered is correct
        if ($user && password_verify($password, $user['password'])) {
            //If the password matches then create a session
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['username'];
            header("Location: dashboard.php");
            exit();
        } else {
            $errors[] = "Invalid email or password.";
        }
    }
}
?>

<?php 
//Hiding the nav bar
$hideNav = true;
include 'inc/header.php'; 
?>

<?php
//If there are any errors, store them in session and redirect to trigger SweetAlert
if (!empty($errors)) {
    $_SESSION['alert_type'] = 'error';
    $_SESSION['alert_message'] = implode('<br>', $errors);
    header("Location: login.php");
    exit;
}
?>

<!--Login form-->
<div class="form-wrapper">
    <form method="POST">
        <label>Email</label>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-envelope"></i></span>
            <input type="email" name="email" placeholder="Enter email">
        </div><br>

        <label>Password:</label>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-key"></i></span>
            <input type="password" name="password" placeholder="Enter password">
        </div>
        <p><a href="forgot_password.php">Forgot your password?</a></p><br>
        
        <button type="submit">Login</button>
        <p>Don't have an account? <a href="register.php">Register here</a></p>
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
