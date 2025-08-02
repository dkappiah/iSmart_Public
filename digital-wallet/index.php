<?php
session_start();
if (isset($_SESSION['user_id'])) {
    //If the user is logged in then redirect to dashboard
    header("Location: dashboard.php");
    exit();
} else {
    //Else redirect them to the login page
    header("Location: login.php");
    exit();
}
?>
