<?php
session_start();

/**
 * Redirects to login page if user is not logged in.
 */
if (!isset($_SESSION['AccNo'])) {
    header('Location: ../login.php?msg=Please login to continue');
    exit;
}

require('../../configs/db.php');
require('pp_check.php'); 
require('../../scripts/get_userinfo.php');

/**
 * Initialize error message variable.
 */
$error = '';
if (isset($_GET['msg'])) {
    $error = $_GET['msg'];
}

$accNo = $_SESSION['AccNo'];

/**
 * Query to get current balance for logged in user.
 */
$sql = "SELECT Balance FROM balance WHERE AccNo = '$accNo'";
$result = mysqli_query($conn, $sql);
$data = mysqli_fetch_assoc($result);
$balance = $data['Balance'];

/**
 * Calculate service charge based on top-up amount.
 *
 * @param float $amount Top-up amount entered by user.
 * @return float Service charge applicable.
 */
function calculateCharge($amount) {
    if ($amount <= 100) return 0.50;
    if ($amount <= 500) return 1.00;
    if ($amount <= 1000) return 2.00;
    if ($amount <= 5000) return 5.00;
    return 10.00; // For amounts above 5000
}

/**
 * Handle form submission for top-up.
 * Validates input amount, calculates charge,
 * updates user balance, logs transactions,
 * and manages fees to the bank account (209).
 */
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['submit'])) {
    $amount = floatval($_POST['amount']);
    $payment_method = $_POST['payment_method'];
    
    $minimum_amount = 1.50;
    $maximum_amount = 100000;
    
    // Validate minimum amount
    if ($amount < $minimum_amount) {
        header('Location: topup.php?msg=Minimum top-up amount is GHc ' . $minimum_amount);
        exit;
    }
    
    // Validate maximum amount
    if ($amount > $maximum_amount) {
        header('Location: topup.php?msg=Maximum top-up amount is GHc ' . number_format($maximum_amount, 2));
        exit;
    }
    
    // Calculate service charge
    $charge = calculateCharge($amount);
    $amount_to_add = $amount - $charge;
    
    // Begin MySQL transaction to ensure atomicity
    mysqli_begin_transaction($conn);
    
    try {
        // Update user balance (amount minus charge)
        $update_sql = "UPDATE balance SET Balance = Balance + $amount_to_add WHERE AccNo = '$accNo'";
        mysqli_query($conn, $update_sql);
        
        // Update bank fee account balance (AccNo 209) with the charge
        $fee_account = 209;
        $update_fee_account = "UPDATE balance SET Balance = Balance + $charge WHERE AccNo = '$fee_account'";
        mysqli_query($conn, $update_fee_account);
        
        // Insert top-up transaction (Sender = 0 for external source)
        $remarks = "Top-up via " . ucfirst(str_replace('_', ' ', $payment_method)) . " (Charge: GHc " . number_format($charge, 2) . ")";
        $insert_sql = "INSERT INTO transactions (Sender, Receiver, Amount, Remarks, SenBalance, RecBalance) 
                      VALUES (0, '$accNo', '$amount_to_add', '$remarks', 0, '$balance' + $amount_to_add)";
        mysqli_query($conn, $insert_sql);
        
        // Insert charge transaction (Sender = user, Receiver = bank fee account)
        $charge_remarks = "Top-up charge for " . ucfirst(str_replace('_', ' ', $payment_method));
        $charge_sql = "INSERT INTO transactions (Sender, Receiver, Amount, Remarks, SenBalance, RecBalance) 
                      VALUES ('$accNo', '$fee_account', '$charge', '$charge_remarks', '$balance' + $amount_to_add, 0)";
        mysqli_query($conn, $charge_sql);
        
        // Commit all DB changes
        mysqli_commit($conn);
        
        // Refresh balance after update
        $result = mysqli_query($conn, $sql);
        $data = mysqli_fetch_assoc($result);
        $balance = $data['Balance'];
        
        // Redirect success message
        header('Location: topup.php?msg=Top-up successful! GHc ' . number_format($amount_to_add, 2) . ' added to your account. GHc ' . number_format($charge, 2) . ' charge applied.');
        exit;
    } catch (Exception $e) {
        // Rollback on error
        mysqli_rollback($conn);
        header('Location: topup.php?msg=Error processing top-up. Please try again.');
        exit;
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Top Up Account - iSmart Bank</title>
    <link rel="icon" href="../../assets/img/ismart.png" type="image/x-icon" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
    />
    <link rel="stylesheet" href="../../pages/dashboard/css/index/Dashboard.css" />
    <style>
        /* Styles for charge table and messages */
        .charge-table {
            width: 100%;
            border-collapse: collapse;
            margin: 1rem 0;
        }
        .charge-table th,
        .charge-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .charge-table th {
            background-color: #f2f2f2;
        }
        .charge-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        #charge-info {
            display: none;
            margin-bottom: 1rem;
            padding: 0.75rem;
            background: #f8f9fa;
            border-radius: 4px;
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
    </style>
    <script>
        /**
         * Calculate the charge based on input amount.
         * @param {number} amount - The amount entered by the user.
         * @returns {number} The calculated service charge.
         */
        function calculateCharge(amount) {
            if (amount <= 100) return 0.5;
            if (amount <= 500) return 1.0;
            if (amount <= 1000) return 2.0;
            if (amount <= 5000) return 5.0;
            return 10.0;
        }

        /**
         * Update the displayed service charge and amount to be added
         * dynamically as the user inputs the amount.
         */
        function updateChargeDisplay() {
            const amountInput = document.getElementById("amount");
            const chargeDisplay = document.getElementById("charge-display");
            const totalDisplay = document.getElementById("total-display");
            const amount = parseFloat(amountInput.value) || 0;
            const charge = calculateCharge(amount);

            if (amount > 0) {
                document.getElementById("amount-display").textContent =
                    "GHc " + amount.toFixed(2);
                chargeDisplay.textContent = "GHc " + charge.toFixed(2);
                totalDisplay.textContent = "GHc " + (amount - charge).toFixed(2);
                document.getElementById("charge-info").style.display = "block";
            } else {
                document.getElementById("charge-info").style.display = "none";
            }
        }
    </script>
</head>

<body>
    <div class="dashboard-container">
     
        <aside class="sidebar">
            <div class="sidebar-brand">
                <img src="../../assets/img/ismart.png" alt="iSmart Bank Logo" />
                <span class="sidebar-brand-text">iSmart Bank</span>
            </div>

            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item">
                        <a href="index.php" class="nav-link">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="./transfer.php" class="nav-link">
                            <i class="fas fa-exchange-alt"></i>
                            <span>Transfer</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="transactions.php" class="nav-link">
                            <i class="fas fa-list"></i>
                            <span>Transactions</span>
                        </a>
                    </li>
                    <li class="nav-item active">
                        <a href="topup.php" class="nav-link">
                            <i class="fas fa-coins"></i>
                            <span>Top up</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="profile.php" class="nav-link">
                            <i class="fas fa-user"></i>
                            <span>Profile</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="settings.php" class="nav-link">
                            <i class="fas fa-cog"></i>
                            <span>Settings</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="../../scripts/logout.php" class="nav-link">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Logout</span>
                        </a>
                    </li>
                </ul>
            </nav>
        </aside>

      
        <main class="main-content">
     
            <header class="top-nav">
                <div class="user-profile" style="margin-left: auto;">
                    <div
                        class="user-avatar"
                        style="background-image: url(<?php echo $pp ?>);"
                    ></div>
                    <span class="user-name"><?php echo $name ?></span>
                </div>
            </header>

            
            <div class="dashboard-content">
                <div class="welcome-header">
                    <h1>Top Up Your Account</h1>
                    <p>Current Balance: GHc <?php echo number_format($balance, 2) ?></p>
                </div>

                <div class="content-grid">
                  
                    <div class="transfer-card" style="max-width: 600px; margin: 0 auto;">
                        <div class="card-header">
                            <h2 class="card-title">Add Funds</h2>
                        </div>

                       
                        <?php if ($error): ?>
                            <div
                                class="<?php echo strpos($error, 'success') !== false
                                    ? 'success-message'
                                    : 'error-message'; ?>"
                            >
                                <?php echo $error ?>
                            </div>
                        <?php endif; ?>

                 
                        <form method="POST" style="padding: 1.5rem;" oninput="updateChargeDisplay()">
                            <div class="form-group">
                                <label for="amount" class="form-label">Amount to Add</label>
                                <div class="input-group">
                                    <span class="input-group-text">GHc</span>
                                    <input
                                        type="number"
                                        class="form-control"
                                        id="amount"
                                        name="amount"
                                        required
                                        min="1.5"
                                        step="0.01"
                                        max="100000"
                                        placeholder="Enter amount"
                                    />
                                </div>
                                <small class="text-muted">Minimum amount: GHc 1.50</small>
                            </div>

                       
                            <div
                                id="charge-info"
                                style="
                                    display: none;
                                    margin-bottom: 1rem;
                                    padding: 0.75rem;
                                    background: #f8f9fa;
                                    border-radius: 4px;
                                "
                            >
                                <div style="display: flex; justify-content: space-between;">
                                    <span>Top-up amount:</span>
                                    <span id="amount-display">GHc 0.00</span>
                                </div>
                                <div style="display: flex; justify-content: space-between;">
                                    <span>Service charge:</span>
                                    <span id="charge-display">GHc 0.00</span>
                                </div>
                                <div
                                    style="
                                        display: flex;
                                        justify-content: space-between;
                                        font-weight: bold;
                                        margin-top: 0.5rem;
                                    "
                                >
                                    <span>Amount to be added:</span>
                                    <span id="total-display">GHc 0.00</span>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="payment_method" class="form-label"
                                    >Payment Method</label
                                >
                                <select
                                    class="form-control"
                                    id="payment_method"
                                    name="payment_method"
                                    required
                                >
                                    <option value="">Select payment method</option>
                                    <option value="credit_card">Credit Card</option>
                                    <option value="debit_card">Debit Card</option>
                                    <option value="bank_transfer">Bank Transfer</option>
                                    <option value="mobile_payment">Mobile Payment</option>
                                </select>
                            </div>

                            <button type="submit" name="submit" class="btn btn-block">
                                <i class="fas fa-plus-circle"></i> Confirm Top-up
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Update charge display when page loads if there's already a value
        document.addEventListener("DOMContentLoaded", function () {
            const amountInput = document.getElementById("amount");
            if (amountInput.value) {
                updateChargeDisplay();
            }
        });
    </script>
</body>
</html>
