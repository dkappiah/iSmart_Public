<?php
session_start();
require_once 'inc/db_connect.php';

//Redirect if the user isn't already logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}

$errors = [];
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $current = $_POST['current_password'];
    $new     = $_POST['new_password'];
    $confirm = $_POST['confirm_password'];

    if (empty($current) || empty($new) || empty($confirm)) {
        $errors[] = "All fields are required.";
    } elseif ($new !== $confirm) {
        $errors[] = "New passwords do not match.";
    } else {
        //Getting the current user
        $stmt = $pdo->prepare("SELECT password FROM users WHERE id = ?");
        $stmt->execute([$_SESSION['user_id']]);
        $user = $stmt->fetch();

        if ($user && password_verify($current, $user['password'])) {

            //Checking if the new password is same as the old password
            if (password_verify($new, $user['password'])) {
                $errors[] = "New password cannot be the same as the current password.";
            } else {
                //Updating the user's password
                $hashed = password_hash($new, PASSWORD_DEFAULT);
                $update = $pdo->prepare("UPDATE users SET password = ? WHERE id = ?");
                $update->execute([$hashed, $_SESSION['user_id']]);

                $_SESSION['alert_type'] = 'success';
                $_SESSION['alert_message'] = 'Password changed successfully.';
            }

        } else {
            $errors[] = "Current password is incorrect.";
        }
    }

    //If there are any errors then set the error alert in session
    if (!empty($errors)) {
        $_SESSION['alert_type'] = 'error';
        $_SESSION['alert_message'] = implode('<br>', $errors);
    }

    header("Location: change_password.php");
    exit;
}
?>

<?php
include 'inc/header.php';
?>

<!--Change Password Form-->
<form method="POST" class="pass-form">
    <label>Current Password</label>
    <input type="password" name="current_password"><br>

    <label>New Password</label>
    <input type="password" name="new_password"><br>

    <label>Confirm New Password</label>
    <input type="password" name="confirm_password"><br>

    <button type="submit">Change Password</button>
</form>

<?php
//Showing the SweetAlert after the redirect
if (isset($_SESSION['alert_type'], $_SESSION['alert_message'])): ?>
<script>
Swal.fire({
    icon: '<?= $_SESSION['alert_type']; ?>',
    title: '<?= $_SESSION['alert_type'] === 'success' ? 'Success!' : 'Error'; ?>',
    html: '<?= $_SESSION['alert_message']; ?>',
    confirmButtonColor: '#3085d6'
});
</script>
<?php
//Clearing the alert from the session so it doesn't show on page refresh
unset($_SESSION['alert_type']);
unset($_SESSION['alert_message']);
endif;
?>