<?php
/**
 * @file
 * handles the fund transfer process between two accounts
 * checks session and form submission
 * verifies account balances and validity
 * updates balances and logs the transaction
 *
 * @package iSmartBank
 * @author Emmanuel
 */

session_start();

/**
 * make sure user is logged in before accessing this page
 */
if (!isset($_SESSION['AccNo'])) {
    header('Location: ../pages/login.php?msg=Please login to continue');
    exit;
}

/**
 * make sure the request came from a proper form submission
 */
if (!isset($_POST['submit'])) {
    header('Location: ../pages/dashboard/index.php?msg=Please make the transaction');
    exit;
}

require('../configs/db.php');

/**
 * @var string $receiver_accNo the account number of the person receiving funds
 * @var float $amount the amount to transfer
 * @var string $remarks optional message or note for the transaction
 * @var string $sender_accNo the currently logged in user making the transfer
 */
$receiver_accNo = $_POST['receiver_accNo'];
$amount = $_POST['amount'];
$remarks = $_POST['remarks'];
$sender_accNo = $_SESSION['AccNo'];

/**
 * get the previous page to handle where to redirect on error
 * @var string $referrer_raw raw value of referrer path
 * @var string $referrer clean filename from referrer url
 */
$referrer_raw = basename($_SERVER['HTTP_REFERER']);
$referrer = explode('?', $referrer_raw)[0];

/**
 * check the balance of the sender before proceeding
 * @var mysqli_result $chk_bal_result query result for sender balance
 * @var float $sender_balance balance of the user sending money
 */
$chk_bal = "SELECT Balance FROM balance WHERE AccNo = '$sender_accNo'";
$chk_bal_result = mysqli_query($conn, $chk_bal);
$sender_balance = mysqli_fetch_assoc($chk_bal_result)['Balance'];

if ($sender_balance < $amount) {
    if ($referrer == 'index.php') {
        header('Location: ../pages/dashboard/index.php?msg=Insufficient Balance');
    } else if ($referrer == 'transfer.php') {
        header('Location: ../pages/dashboard/transfer.php?msg=Insufficient Balance');
    }
    exit;
}

/**
 * make sure receiver account exists and is not the same as sender
 * @var mysqli_result $chk_acc_result result of receiver account check
 */
$chk_acc = "SELECT AccNo FROM credentials WHERE AccNo = '$receiver_accNo'";
$chk_acc_result = mysqli_query($conn, $chk_acc);

if (mysqli_num_rows($chk_acc_result) == 0 || $receiver_accNo == $sender_accNo) {
    if ($referrer == 'index.php') {
        header('Location: ../pages/dashboard/index.php?msg=Invalid Account Number');
    } else if ($referrer == 'transfer.php') {
        header('Location: ../pages/dashboard/transfer.php?msg=Invalid Account Number');
    }
    exit;
}

/**
 * @var float $receiver_balance the current balance of the receiver before transfer
 */
$receiver_balance = mysqli_fetch_assoc(mysqli_query($conn, "SELECT Balance FROM balance WHERE AccNo = '$receiver_accNo'"))['Balance'];

/**
 * update both sender and receiver balances
 */
$sender_balance -= $amount;
$receiver_balance += $amount;

/**
 * store the current balances for transaction history
 */
$curr_sen_balance = $sender_balance;
$curr_rec_balance = $receiver_balance;

/**
 * update sender balance in the balance table
 * @var mysqli_result $update_sender_balance_result update result for sender
 */
$update_sender_balance = "UPDATE balance SET Balance = '$sender_balance' WHERE AccNo = '$sender_accNo'";
$update_sender_balance_result = mysqli_query($conn, $update_sender_balance);

/**
 * update receiver balance in the balance table
 * @var mysqli_result $update_receiver_balance_result update result for receiver
 */
$update_receiver_balance = "UPDATE balance SET Balance = '$receiver_balance' WHERE AccNo = '$receiver_accNo'";
$update_receiver_balance_result = mysqli_query($conn, $update_receiver_balance);

/**
 * insert transaction record into the transactions table
 * @var mysqli_result $insert_transaction_result result of the insert query
 */
$insert_transaction = "INSERT INTO transactions (Sender, Receiver, Amount, Remarks, SenBalance, RecBalance) VALUES ('$sender_accNo', '$receiver_accNo', '$amount', '$remarks', '$curr_sen_balance', '$curr_rec_balance')";
$insert_transaction_result = mysqli_query($conn, $insert_transaction);

/**
 * redirect to the appropriate page after transaction success
 */
if ($referrer == 'index.php') {
    header('Location: ../pages/dashboard/index.php?msg=Transaction Successful');
} else if ($referrer == 'transfer.php') {
    header('Location: ../pages/dashboard/transfer.php?msg=Transaction Successful');
}

exit;
