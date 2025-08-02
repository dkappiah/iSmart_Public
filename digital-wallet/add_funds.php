<?php
session_start();
require_once 'inc/db_connect.php';

//Redirect to login page if the user is not logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

$success = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $amount = floatval($_POST['amount']);

    if ($amount <= 0) {
        $error = "Please enter a valid amount.";
    } else {
        //Update the user's balance
        $stmt = $pdo->prepare("UPDATE users SET balance = balance + ? WHERE id = ?");
        $stmt->execute([$amount, $_SESSION['user_id']]);

        //Logging the transaction
        $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount) VALUES (?, 'add', ?)");
        $stmt->execute([$_SESSION['user_id'], $amount]);

        $success = "GHS " . number_format($amount, 2) . " added successfully to your wallet.";
    }
}
?>

<?php include 'inc/header.php'; ?>
<h2>Add Funds</h2>

<?php
//If there's an error then store it in session and redirect to show SweetAlert
if ($error) {
    $_SESSION['alert_type'] = 'error';
    $_SESSION['alert_message'] = $error;
    header("Location: add_funds.php");
    exit;
}

//If the transaction was successful then show the success alert
if ($success) {
    $_SESSION['alert_type'] = 'success';
    $_SESSION['alert_message'] = $success;
    header("Location: add_funds.php");
    exit;
}
?>

<!--HTML form to add funds to the user's wallet-->
<form id="add-funds-form" method="POST">
    <label>Amount (GHS):</label><br>
    <input type="number" step="0.01" name="amount" required><br><br>

    <button type="submit">Add Funds</button>
</form>

<script>
//SweetAlert confirmation before submitting the form
document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('add-funds-form');

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        
        const amount = parseFloat(form.amount.value);

        //Frontend validation
        if (!amount || amount <= 0) {
            Swal.fire({
                icon: 'error',
                title: 'Invalid Amount',
                text: 'Please enter a valid amount greater than 0.'
            });
            return;
        }

        //SweetAlert for confirming adding of funds to the wallet
        Swal.fire({
            title: `Add GHS ${amount.toFixed(2)} to wallet?`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Yes, add it!',
            cancelButtonText: 'No, cancel',
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33'
        }).then((result) => {
            if (result.isConfirmed) {
                form.submit();
            }
        });
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
