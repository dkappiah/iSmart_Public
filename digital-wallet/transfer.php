<?php
session_start();
require_once 'inc/db_connect.php';
require_once 'inc/send_email.php';

//Redirect if the user isn't already logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

$success = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $recipient_input = trim($_POST['recipient']);
    $amount = floatval($_POST['amount']);

    if (empty($recipient_input) || $amount <= 0) {
        $error = "Please enter valid recipient and amount.";
    } else {
        //Finding recipient either by username or email
        $stmt = $pdo->prepare("SELECT id FROM users WHERE (username = ? OR email = ?) AND id != ?");
        $stmt->execute([$recipient_input, $recipient_input, $_SESSION['user_id']]);
        $recipient = $stmt->fetch();

        if (!$recipient) {
            $error = "Recipient not found or invalid.";
        } else {
            //Checking the sender's balance
            $stmt = $pdo->prepare("SELECT balance FROM users WHERE id = ?");
            $stmt->execute([$_SESSION['user_id']]);
            $sender = $stmt->fetch();

            if ($sender['balance'] < $amount) {
                $error = "Insufficient balance.";
            } else {
                //Deducting from the sender's account balance
                $stmt = $pdo->prepare("UPDATE users SET balance = balance - ? WHERE id = ?");
                $stmt->execute([$amount, $_SESSION['user_id']]);

                //Adding to recipient's account balance
                $stmt = $pdo->prepare("UPDATE users SET balance = balance + ? WHERE id = ?");
                $stmt->execute([$amount, $recipient['id']]);

                //Logging transaction
                $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, reference_user) VALUES (?, 'transfer', ?, ?)");
                $stmt->execute([$_SESSION['user_id'], $amount, $recipient['id']]);

                $success = "GHS " . number_format($amount, 2) . " successfully transferred.";

                //Notifying the recipient via email about the transfer
                $recipient_email_stmt = $pdo->prepare("SELECT email FROM users WHERE id = ?");
                $recipient_email_stmt->execute([$recipient['id']]);
                $recipient_email = $recipient_email_stmt->fetchColumn();

                $emailBody = "
                    <h3>You've received GHS $amount</h3>
                    <p>From: {$_SESSION['username']}</p>
                    <p>Date: " . date('Y-m-d H:i') . "</p>
                    <p>Thank you for using DigiPay.</p>
                ";

                sendEmail($recipient_email, "Wallet Transfer Received", $emailBody);
            }
        }
    }
}
?>

<?php include 'inc/header.php'; ?>
<h2>Transfer Funds</h2>

<?php
//If there's an error then store it in session and redirect to show SweetAlert
if ($error) {
    $_SESSION['alert_type'] = 'error';
    $_SESSION['alert_message'] = $error;
    header("Location: transfer.php");
    exit;
}

//If the transaction was successful then show the success alert
if ($success) {
    $_SESSION['alert_type'] = 'success';
    $_SESSION['alert_message'] = $success;
    header("Location: transfer.php");
    exit;
}
?>

<!--HTML form to transfer funds to another user's wallet-->
<form id="transferForm" method="POST">
    <label>Recipient (Username or Email):</label><br>
    <input type="text" name="recipient" required><br><br>

    <label>Amount (GHS):</label><br>
    <input type="number" name="amount" step="0.01" required><br><br>

    <button type="submit">Transfer</button>
</form>

<script>
    //SweetAlert confirmation before submitting the form
document.getElementById('transferForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const recipient = document.querySelector('input[name="recipient"]').value;
    const amount = document.querySelector('input[name="amount"]').value;

    //SweetAlert for confirming adding of funds to the wallet
    Swal.fire({
        title: 'Confirm Transfer',
        html: `Transfer <strong>GHS ${parseFloat(amount).toFixed(2)}</strong> to <strong>${recipient}</strong>?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Yes, transfer',
        cancelButtonText: 'No, cancel',
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33'
    }).then((result) => {
        if (result.isConfirmed) {
            document.getElementById('transferForm').submit();
        }
    });
});
</script>

<?php 
//Showing the SweetAlert after the redirect
if (isset($_SESSION['alert_type']) && isset($_SESSION['alert_message'])): ?>
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
