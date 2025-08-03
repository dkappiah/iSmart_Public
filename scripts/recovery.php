<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
session_start();

require_once('/Applications/XAMPP/xamppfiles/htdocs/bankSystem/configs/db.php');

if (isset($_POST['verify_info'])) {
    $email = mysqli_real_escape_string($conn, $_POST['email']);
    $address = mysqli_real_escape_string($conn, $_POST['address']);

    $sql = "SELECT AccNo FROM userinfo WHERE Email = '$email' AND Address = '$address'";
    $result = mysqli_query($conn, $sql);
    
    if (mysqli_num_rows($result) == 0) {
        $_SESSION['error'] = "The email and address combination was not found";
        header("Location: recovery.php");
        exit();
    }
    
    $_SESSION['recovery'] = [
        'email' => $email,
        'verified' => true
    ];
    
    header("Location: recovery.php");
    exit();
}

if (isset($_POST['reset_password'])) {
    if (!isset($_SESSION['recovery']['verified'])) {
        $_SESSION['error'] = "Please verify your information first";
        header("Location: recovery.php");
        exit();
    }
    
    $newPassword = password_hash($_POST['new_password'], PASSWORD_DEFAULT);
    $email = $_SESSION['recovery']['email'];
    
    mysqli_query($conn, "UPDATE credentials SET Pass = '$newPassword' 
              WHERE AccNo = (SELECT AccNo FROM userinfo WHERE Email = '$email')");
    
    $_SESSION['success'] = "Your password has been updated successfully";
    unset($_SESSION['recovery']);
    header("Location:../pages/login.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Recovery - iSmart Bank</title>
    <link rel="stylesheet" href="../pages/dashboard/css/index/home.css">
    <style>
        .recovery-container {
            max-width: 500px;
            margin: 4rem auto;
            padding: 2rem;
            background: var(--white);
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }
        .recovery-container h2 {
            color: var(--primary-dark);
            margin-bottom: 1.5rem;
            text-align: center;
        }
        .form-group {
            margin-bottom: 1.5rem;
        }
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: var(--text);
            font-weight: 500;
        }
        .form-group input {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
        }
        .btn-recovery {
            width: 100%;
            padding: 0.8rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-recovery:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
        }
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }
        .alert-success {
            background: rgba(74, 222, 128, 0.2);
            color: #16a34a;
            border-left: 4px solid #16a34a;
        }
        .alert-error {
            background: rgba(248, 113, 113, 0.2);
            color: #dc2626;
            border-left: 4px solid #dc2626;
        }
        .text-center {
            text-align: center;
        }
    </style>
</head>
<body>
    <header>
        <div class="navbar">
            <a href="../index.php" class="logo">
                <img src="../assets/img/ismart.png" alt="iSmart Bank">
                iSmart Bank
            </a>
            <div class="nav-links">
                <a href="../pages/home.php">Home</a>
                <a href="../../pages/login.php">Login</a>
            </div>
        </div>
    </header>

    <main>
        <div class="recovery-container">
            <h2>🔒 Password Recovery</h2>
            
            <?php if (isset($_SESSION['error'])): ?>
                <div class="alert alert-error">
                    <?php echo $_SESSION['error']; unset($_SESSION['error']); ?>
                </div>
            <?php endif; ?>
            
            <?php if (isset($_SESSION['success'])): ?>
                <div class="alert alert-success">
                    <?php echo $_SESSION['success']; unset($_SESSION['success']); ?>
                </div>
            <?php endif; ?>
            
            <?php if (!isset($_SESSION['recovery'])): ?>
                <form method="post" action="recovery.php">
                    <div class="form-group">
                        <label for="email">Your Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="address">Your Registered Address</label>
                        <input type="text" id="address" name="address" required>
                    </div>
                    <button type="submit" name="verify_info" class="btn-recovery">Verify Information</button>
                </form>
            <?php else: ?>
                <form method="post" action="recovery.php">
                    <div class="form-group">
                        <label for="new_password">New Password</label>
                        <input type="password" id="new_password" name="new_password" minlength="8" required>
                    </div>
                    <div class="form-group">
                        <label for="confirm_password">Confirm Password</label>
                        <input type="password" id="confirm_password" name="confirm_password" minlength="8" required>
                    </div>
                    <button type="submit" name="reset_password" class="btn-recovery">Update Password</button>
                </form>
            <?php endif; ?>
            
            <div class="text-center" style="margin-top: 1.5rem;">
                <a href="../pages/login.php" style="color: var(--primary);">← Back to Login</a>
            </div>
        </div>
    </main>
</body>
</html>