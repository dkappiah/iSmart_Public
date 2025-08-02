<?php
session_start();
require_once 'inc/db_connect.php';

$token = $_GET['token'] ?? '';
$errors = [];

//Checking if the token is missing
if (empty($token)) {
    $_SESSION['alert_type'] = 'error';
    $_SESSION['alert_message'] = 'Invalid or missing token.';
    header("Location: login.php");
    exit;
}

//Fetching the reset record from the database using the token
$stmt = $pdo->prepare("SELECT email, expires_at FROM password_resets WHERE token = ?");
$stmt->execute([$token]);
$reset = $stmt->fetch();

//If no record found or token has expired
if (!$reset || strtotime($reset['expires_at']) < time()) {
    $_SESSION['alert_type'] = 'error';
    $_SESSION['alert_message'] = 'Reset link is invalid or has expired.';
    header("Location: login.php");
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $new     = $_POST['new_password'];
    $confirm = $_POST['confirm_password'];

    //Validating password inputs
    if (empty($new) || empty($confirm)) {
        $errors[] = "All fields are required.";
    } elseif ($new !== $confirm) {
        $errors[] = "Passwords do not match.";
    }

    if (empty($errors)) {
        $hashed = password_hash($new, PASSWORD_DEFAULT);

        //Updating the password
        $pdo->prepare("UPDATE users SET password = ? WHERE email = ?")
            ->execute([$hashed, $reset['email']]);

        //Deleting the used token
        $pdo->prepare("DELETE FROM password_resets WHERE token = ?")
            ->execute([$token]);

        $_SESSION['alert_type'] = 'success';
        $_SESSION['alert_message'] = 'Password updated successfully. Please log in.';
        header("Location: login.php");
        exit;
    } else {
        //If any errors exist then show them and reload the page
        $_SESSION['alert_type'] = 'error';
        $_SESSION['alert_message'] = implode('<br>', $errors);
        header("Location: reset_password.php?token=" . urlencode($token));
        exit;
    }
}
?>

<?php
$hideNav = true;
include 'inc/header.php';
?>

<h2>Reset Your Password</h2>

<!--Password Reset Form-->
<div class="form-wrapper">
    <form method="POST">
        <label>New Password:</label><br>
        <input type="password" name="new_password" required><br><br>

        <label>Confirm Password:</label><br>
        <input type="password" name="confirm_password" required><br><br>

        <button type="submit">Update Password</button>
    </form>
</div>

<?php 
//Showing the SweetAlert after the redirect
if (isset($_SESSION['alert_type'], $_SESSION['alert_message'])): ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
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
