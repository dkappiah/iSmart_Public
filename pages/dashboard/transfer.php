<?php
session_start();
if (!isset($_SESSION['AccNo'])) {
    header('Location: ../login.php?msg=Please login to continue');
    exit;
}

require('../../configs/db.php');
require('pp_check.php'); // PP Check
require('../../scripts/get_userinfo.php'); // $fName

// Initialize variables
$error = '';
$success = '';
$balance = 0;

// Get account balance
$accNo = $_SESSION['AccNo'];
$sql = "SELECT Balance FROM balance WHERE AccNo = '$accNo'";
$result = mysqli_query($conn, $sql);
$data = mysqli_fetch_assoc($result);
$balance = $data['Balance'];

// Function to calculate transfer charge based on amount
function calculateTransferCharge($amount) {
    if ($amount <= 100) return 0.50;
    if ($amount <= 500) return 1.00;
    if ($amount <= 1000) return 2.00;
    if ($amount <= 5000) return 5.00;
    return 10.00; // For amounts above 5000
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['submit'])) {
    $receiver_accNo = mysqli_real_escape_string($conn, $_POST['receiver_accNo']);
    $amount = floatval($_POST['amount']);
    $remarks = mysqli_real_escape_string($conn, $_POST['remarks']);
    
    // Validate inputs
    if (empty($receiver_accNo) || empty($amount)) {
        $error = "Please fill all required fields";
    } elseif ($amount <= 0) {
        $error = "Amount must be greater than zero";
    } elseif ($receiver_accNo == $accNo) {
        $error = "You cannot transfer to yourself";
    } else {
        // Check if receiver exists
        $receiver_check = "SELECT * FROM balance WHERE AccNo = '$receiver_accNo'";
        $receiver_result = mysqli_query($conn, $receiver_check);
        
        if (mysqli_num_rows($receiver_result) == 0) {
            $error = "Receiver account not found";
        } else {
            // Calculate charge and total deduction
            $charge = calculateTransferCharge($amount);
            $total_deduction = $amount + $charge;
            
            // Check sufficient balance
            if ($balance < $total_deduction) {
                $error = "Insufficient balance (including transfer fee)";
            } else {
                // Start transaction
                mysqli_begin_transaction($conn);
                
                try {
                    // 1. Deduct amount + charge from sender
                    $update_sender = "UPDATE balance SET Balance = Balance - $total_deduction WHERE AccNo = '$accNo'";
                    mysqli_query($conn, $update_sender);
                    
                    // 2. Add amount to receiver (without charge)
                    $update_receiver = "UPDATE balance SET Balance = Balance + $amount WHERE AccNo = '$receiver_accNo'";
                    mysqli_query($conn, $update_receiver);
                    
                    // 3. Add charge (fee) to account 209
                    $fee_account = 209;
                    $update_fee_account = "UPDATE balance SET Balance = Balance + $charge WHERE AccNo = '$fee_account'";
                    mysqli_query($conn, $update_fee_account);
                    
                    // Get balances after updates for recording in transactions
                    $sender_balance_after = $balance - $total_deduction;
                    
                    // Get receiver balance after update
                    $receiver_balance_after_query = mysqli_query($conn, "SELECT Balance FROM balance WHERE AccNo = '$receiver_accNo'");
                    $receiver_balance_after_data = mysqli_fetch_assoc($receiver_balance_after_query);
                    $receiver_balance_after = $receiver_balance_after_data['Balance'];
                    
                    // Get fee account balance after update
                    $fee_balance_after_query = mysqli_query($conn, "SELECT Balance FROM balance WHERE AccNo = '$fee_account'");
                    $fee_balance_after_data = mysqli_fetch_assoc($fee_balance_after_query);
                    $fee_balance_after = $fee_balance_after_data['Balance'];
                    
                    // 4. Record the transfer transaction
                    $transfer_remarks = $remarks ?: "Transfer to $receiver_accNo";
                    $insert_transfer = "INSERT INTO transactions (Sender, Receiver, Amount, Remarks, SenBalance, RecBalance) 
                                      VALUES ('$accNo', '$receiver_accNo', '$amount', '$transfer_remarks', 
                                              '$balance', '$sender_balance_after')";
                    mysqli_query($conn, $insert_transfer);
                    
                    // 5. Record the charge transaction - fee moved to account 209
                    $charge_remarks = "Transfer fee for sending GHc " . number_format($amount, 2) . " to $receiver_accNo";
                    $insert_charge = "INSERT INTO transactions (Sender, Receiver, Amount, Remarks, SenBalance, RecBalance) 
                                     VALUES ('$accNo', '$fee_account', '$charge', '$charge_remarks', 
                                             '$sender_balance_after', '$sender_balance_after')";
                    mysqli_query($conn, $insert_charge);
                    
                    // Commit transaction
                    mysqli_commit($conn);
                    
                    // Refresh balance
                    $result = mysqli_query($conn, $sql);
                    $data = mysqli_fetch_assoc($result);
                    $balance = $data['Balance'];
                    
                    $success = "Transfer successful! GHc " . number_format($amount, 2) . 
                               " sent to account $receiver_accNo. Fee: GHc " . number_format($charge, 2);
                } catch (Exception $e) {
                    mysqli_rollback($conn);
                    $error = "Error processing transfer. Please try again.";
                }
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transfer Funds - iSmart Bank</title>
    <link rel="icon" href="../../assets/img/ismart.png" type="image/x-icon">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="../../pages/dashboard/css/index/Dashboard.css">
    <style>
        .charge-table {
            width: 100%;
            border-collapse: collapse;
            margin: 1rem 0;
        }
        .charge-table th, .charge-table td {
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
        function calculateTransferCharge(amount) {
            if (amount <= 100) return 0.50;
            if (amount <= 500) return 1.00;
            if (amount <= 1000) return 2.00;
            if (amount <= 5000) return 5.00;
            return 10.00;
        }

        function updateChargeDisplay() {
            const amountInput = document.getElementById('amount');
            const chargeDisplay = document.getElementById('charge-display');
            const totalDisplay = document.getElementById('total-display');
            const amount = parseFloat(amountInput.value) || 0;
            const charge = calculateTransferCharge(amount);
            
            if (amount > 0) {
                document.getElementById('amount-display').textContent = 'GHc ' + amount.toFixed(2);
                chargeDisplay.textContent = 'GHc ' + charge.toFixed(2);
                totalDisplay.textContent = 'GHc ' + (amount + charge).toFixed(2);
                document.getElementById('charge-info').style.display = 'block';
            } else {
                document.getElementById('charge-info').style.display = 'none';
            }
        }
    </script>
</head>

<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <img src="../../assets/img/ismart.png" alt="iSmart Bank Logo">
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
                    <li class="nav-item active">
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
                    <li class="nav-item">
                        <a href="Topup.php" class="nav-link">
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

        <!-- Main Content -->
        <main class="main-content">
            <!-- Top Navigation -->
            <header class="top-nav">
                <div class="user-profile" style="margin-left: auto;">
                    <div class="user-avatar" style="background-image: url(<?php echo $pp ?>);"></div>
                    <span class="user-name"><?php echo $name ?></span>
                </div>
            </header>

            <!-- Transfer Content -->
            <div class="dashboard-content">
                <div class="welcome-header">
                    <h1>Transfer Funds</h1>
                    <p>Current Balance: GHc <?php echo number_format($balance, 2) ?></p>
                </div>

                <div class="content-grid">
                    <!-- Transfer Form -->
                    <div class="transfer-card" style="max-width: 600px; margin: 0 auto;">
                        <div class="card-header">
                            <h2 class="card-title">Make a Transfer</h2>
                        </div>
                        
                        <?php if ($success): ?>
                        <div class="success-message"><?php echo $success ?></div>
                        <?php endif; ?>
                        
                        <form method="POST" style="padding: 1.5rem;" oninput="updateChargeDisplay()">
                            <div class="form-group">
                                <label for="receiver_accNo" class="form-label">Account Number</label>
                                <input type="text" class="form-control" id="receiver_accNo" name="receiver_accNo" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="amount" class="form-label">Amount to Transfer</label>
                                <div class="input-group">
                                    <span class="input-group-text">GHc</span>
                                    <input type="number" class="form-control" id="amount" name="amount" required 
                                           min="1" step="0.01" max="100000" placeholder="Enter amount">
                                </div>
                                <small class="text-muted">Minimum transfer: GHc 1.00</small>
                            </div>
                            
                            <div id="charge-info">
                                <div style="display: flex; justify-content: space-between;">
                                    <span>Transfer amount:</span>
                                    <span id="amount-display">GHc 0.00</span>
                                </div>
                                <div style="display: flex; justify-content: space-between;">
                                    <span>Transfer fee:</span>
                                    <span id="charge-display">GHc 0.00</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; font-weight: bold; margin-top: 0.5rem;">
                                    <span>Total to deduct:</span>
                                    <span id="total-display">GHc 0.00</span>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="remarks" class="form-label">Remarks (Optional)</label>
                                <input type="text" class="form-control" id="remarks" name="remarks" placeholder="e.g. For groceries">
                            </div>
                            
                            <?php if ($error): ?>
                            <div class="error-message"><?php echo $error ?></div>
                            <?php endif; ?>
                            
                            <button type="submit" name="submit" class="btn btn-block">
                                <i class="fas fa-exchange-alt"></i> Transfer Now
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

</body>
</html>
