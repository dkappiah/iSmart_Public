<?php
/**
 * @file
 * Login handler for iSmartBank.
 *
 * Validates user login form submission, checks credentials in the database,
 * verifies password hash and starts a session for authenticated users.
 * If authentication fails redirects with appropriate error messages.
 *
 * @package iSmartBank
 * @author Emmanuel
 */

// Redirect if the login form was not submitted
if (!isset($_POST['submit'])) {
    header('Location: ../pages/login.php');
    exit;
}

require('../configs/db.php');

/**
 * @var string $accNo The account number input from the login form
 * @var string $password The plaintext password input from the login form
 */
$accNo = $_POST['accountNumber'];
$password = $_POST['password'];

/**
 * Query to retrieve user credentials based on account number.
 *
 * @var string $sql
 * @var mysqli_result|false $result The result set returned by the database query
 */
$sql = "SELECT * FROM credentials WHERE AccNo = '$accNo'";
$result = mysqli_query($conn, $sql);

// Redirect if the database query fails
if (!$result) {
    header('Location: ../pages/login.php?msg=Cannot connect to database');
    exit;
}

/**
 * @var array|null $data User data from the credentials table (if found)
 */
$data = mysqli_fetch_assoc($result);

if ($data) {
    /**
     * @var string $hashed_password The hashed password stored in the database
     */
    $hashed_password = $data['Pass'];

    /**
     * Verifies the user's input password with the hashed password from the database.
     *
     * @param string $password The user-entered raw password
     * @param string $hashed_password The password hash from the DB
     * @return bool True if the password is correct, false otherwise
     */
    if (password_verify($password, $hashed_password)) {
        session_start();
        $_SESSION['AccNo'] = $data['AccNo'];

        // Redirect to dashboard on successful login
        header('Location: ../pages/dashboard/index.php');
        exit;
    } else {
        // Password mismatch
        header('Location: ../pages/login.php?msg=Invalid Credentials');
        exit;
    }
} else {
    // No account found with that number
    header('Location: ../pages/login.php?msg=Account number does not exist');
    exit;
}
