<?php
/**
 * Handles updating the user's account information (name, email, address).
 *
 * @throws Redirects the user if:
 *   - The 'change' POST parameter is not set.
 *   - Any of the required fields (name, email, address) are empty.
 *   - The database update query fails.
 *
 * @uses $_SESSION['AccNo'] to identify the currently logged-in user.
 * @uses $_POST['name'] The new name to update.
 * @uses $_POST['email'] The new email to update.
 * @uses $_POST['address'] The new address to update.
 */

// Start session and load database connection
session_start();
require('../configs/db.php');

// Verify that the form submission is valid
if (!isset($_POST['change'])) {
    header('Location: ../pages/dashboard/settings.php?msg=Please send a query');
    exit;
}

// Retrieve and sanitize user inputs
$name = $_POST['name'];
$email = $_POST['email'];
$address = $_POST['address'];

// Check for empty fields and redirect with error if any are missing
if (empty($name) || empty($email) || empty($address)) {
    header('Location: ../pages/dashboard/settings.php?msg=Please fill all the fields');
    exit;
}

// Prepare and execute the update query to change user info
$sql = "UPDATE userinfo SET Name='$name', Email='$email', Address='$address' WHERE AccNo =" . $_SESSION['AccNo'];
$update_sql = mysqli_query($conn, $sql);

// Redirect with error message if update failed
if (!$update_sql) {
    header('Location: ../pages/dashboard/settings.php?msg=Account info change failed');
    exit;
}

// Redirect to settings page with success message
header('Location: ../pages/dashboard/settings.php?msg=Account info changed successfully');
exit;
