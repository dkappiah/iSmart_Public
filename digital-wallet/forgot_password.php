<?php
session_start();
require_once 'inc/db_connect.php';
require_once 'inc/send_email.php';

$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email']);

    if (empty($email)) {
        $errors[] = "Please enter your email address.";
    } else {
        //Checking if the email exists
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if ($user) {
            $token = bin2hex(random_bytes(32));
            $expires = date("Y-m-d H:i:s", time() + 3600); //The token expires after 1 hour

            $pdo->prepare("DELETE FROM password_resets WHERE email = ?")->execute([$email]);

            //Inserting the new token in the database
            $pdo->prepare("INSERT INTO password_resets (email, token, expires_at) VALUES (?, ?, ?)")
                ->execute([$email, $token, $expires]);

            $resetLink = "http://localhost/digital-wallet/reset_password.php?token=$token";

            //Sending the reset link via email
            sendEmail($email, 'Password Reset Request', "Click to reset your password: <br><a href='$resetLink'>$resetLink</a>");

            $_SESSION['alert_type'] = 'success';
            $_SESSION['alert_message'] = 'A password reset link has been sent to your email.';
        } else {
            $errors[] = "No account found with that email.";
        }
    }

    //Handling errors
    if (!empty($errors)) {
        $_SESSION['alert_type'] = 'error';
        $_SESSION['alert_message'] = implode('<br>', $errors);
    }

    header("Location: forgot_password.php");
    exit;
}
?>

<?php
//Hiding the navbar while the user is not logged in
$hideNav = true;
include 'inc/header.php';
?>

<!--Password Reset Request Form-->
<div class="form-wrapper">
    <form method="POST">
        <label>Email:</label><br>
        <div class="input-wrapper">
            <span class="input-icon"><i class="fa-solid fa-envelope"></i></span>
            <input type="email" name="email" placeholder="Enter email">
        </div><br>
        
        <button type="submit">Send Reset Link</button>
        <p>Remember your password? <a href="login.php">Log in</a></p>
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
