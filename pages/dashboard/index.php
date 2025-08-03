<?php
session_start();
if (!isset($_SESSION['AccNo'])) {
    header('Location: ../login.php?msg=Please login to continue');
    exit;
}

require('../../configs/db.php');
require('pp_check.php');
require('../../scripts/get_userinfo.php');

$accNo = $_SESSION['AccNo'];
$balance_query = "SELECT Balance FROM balance WHERE AccNo = '$accNo'";
$balance_result = mysqli_query($conn, $balance_query);
$balance_data = mysqli_fetch_assoc($balance_result);
$balance = $balance_data['Balance'];

$credit_query = "SELECT SUM(Amount) as total_credit FROM transactions WHERE Receiver = '$accNo' AND Sender != 0";
$credit_result = mysqli_query($conn, $credit_query);
$credit_data = mysqli_fetch_assoc($credit_result);
$totalCredit = $credit_data['total_credit'] ?? 0;

$debit_query = "SELECT SUM(Amount) as total_debit FROM transactions WHERE Sender = '$accNo' AND Sender != 0";
$debit_result = mysqli_query($conn, $debit_query);
$debit_data = mysqli_fetch_assoc($debit_result);
$totalDebit = $debit_data['total_debit'] ?? 0;

$transactions_query = "SELECT t.*, 
                      sender.Name as sender_name, 
                      receiver.Name as receiver_name 
                      FROM transactions t
                      LEFT JOIN userinfo sender ON t.Sender = sender.AccNo
                      LEFT JOIN userinfo receiver ON t.Receiver = receiver.AccNo
                      WHERE t.Sender = '$accNo' OR t.Receiver = '$accNo'
                      ORDER BY t.DateTime DESC LIMIT 7";
$trns_result = mysqli_query($conn, $transactions_query);
$trns = [];
while ($row = mysqli_fetch_assoc($trns_result)) {
    $trns[] = $row;
}

$error = '';
if (isset($_GET['msg'])) {
    $error = $_GET['msg'];
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - iSmart Bank</title>
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
    </style>
</head>

<body>
    <div class="dashboard-container">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <img src="../../assets/img/ismart.png" alt="iSmart Bank Logo">
                <span class="sidebar-brand-text">iSmart Bank</span>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li class="nav-item active">
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

        <main class="main-content">
            <header class="top-nav">
                <div class="user-profile" style="margin-left: auto;">
                    <div class="user-avatar" style="background-image: url(<?php echo $pp ?>);"></div>
                    <span class="user-name"><?php echo $name ?></span>
                </div>
            </header>

            <div class="dashboard-content">
                <div class="welcome-header">
                    <h1>Welcome back, <?php echo $fName ?></h1>
                    <p>Here's what's happening with your account today</p>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <span class="stat-card-title">Current Balance</span>
                            <div class="stat-card-icon balance">
                                <i class="fas fa-wallet"></i>
                            </div>
                        </div>
                        <div class="stat-card-value">GHc <?php echo number_format($balance, 2) ?></div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <span class="stat-card-title">Total Income</span>
                            <div class="stat-card-icon income">
                                <i class="fas fa-arrow-down"></i>
                            </div>
                        </div>
                        <div class="stat-card-value">GHc <?php echo number_format($totalCredit, 2) ?></div>
                        <div class="stat-card-footer">Money received from transfers</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <span class="stat-card-title">Total Expenses</span>
                            <div class="stat-card-icon expense">
                                <i class="fas fa-arrow-up"></i>
                            </div>
                        </div>
                        <div class="stat-card-value">GHc <?php echo number_format($totalDebit, 2) ?></div>
                        <div class="stat-card-footer">Money sent to others</div>
                    </div>
                </div>

                <div class="content-grid">
                    <div class="transactions-card">
                        <div class="card-header">
                            <h2 class="card-title">Recent Transactions</h2>
                        </div>
                        
                        <div class="table-responsive">
                            <table class="transactions-table">
                                <thead>
                                    <tr>
                                        <th>Type</th>
                                        <th>Description</th>
                                        <th>Amount</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php
                                    foreach ($trns as $trn) {
                                        $date = date("d-m-Y", strtotime($trn['DateTime']));
                                        $sender = $trn['Sender'];
                                        $receiver = $trn['Receiver'];
                                        $sender_name = $trn['sender_name'];
                                        $receiver_name = $trn['receiver_name'];
                                        $amount = $trn['Amount'];
                                        $remarks = $trn['Remarks'];
                                        
                                        if ($sender == 0) {
                                            echo "<tr>
                                                <td><span class='transaction-type credit'>Credit</span></td>
                                                <td>Account Top-up<br><small>$remarks</small></td>
                                                <td class='transaction-amount'>+ GHc " . number_format($amount, 2) . "</td>
                                                <td>$date</td>
                                            </tr>";
                                        }
                                        elseif ($sender == $accNo) {
                                            echo "<tr>
                                                <td><span class='transaction-type debit'>Debit</span></td>
                                                <td>Transfer to $receiver_name<br><small>$remarks</small></td>
                                                <td class='transaction-amount'>- GHc " . number_format($amount, 2) . "</td>
                                                <td>$date</td>
                                            </tr>";
                                        } else {
                                            echo "<tr>
                                                <td><span class='transaction-type credit'>Credit</span></td>
                                                <td>Transfer from $sender_name<br><small>$remarks</small></td>
                                                <td class='transaction-amount'>+ GHc " . number_format($amount, 2) . "</td>
                                                <td>$date</td>
                                            </tr>";
                                        }
                                    }
                                    ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <div class="charges-section">
                        <h3>Transfer Charges</h3>
                        <table class="charge-table">
                            <thead>
                                <tr>
                                    <th>Amount Range</th>
                                    <th>Charge</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>GHc 1 - GHc 100</td>
                                    <td>GHc 0.50</td>
                                </tr>
                                <tr>
                                    <td>GHc 101 - GHc 500</td>
                                    <td>GHc 1.00</td>
                                </tr>
                                <tr>
                                    <td>GHc 501 - GHc 1,000</td>
                                    <td>GHc 2.00</td>
                                </tr>
                                <tr>
                                    <td>GHc 1,001 - GHc 5,000</td>
                                    <td>GHc 5.00</td>
                                </tr>
                                <tr>
                                    <td>GHc 5,001 and above</td>
                                    <td>GHc 10.00</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const sidebar = document.querySelector('.sidebar');
            const toggleBtn = document.createElement('button');
            toggleBtn.innerHTML = '<i class="fas fa-bars"></i>';
            toggleBtn.style.position = 'fixed';
            toggleBtn.style.top = '15px';
            toggleBtn.style.left = '15px';
            toggleBtn.style.zIndex = '1000';
            toggleBtn.style.background = 'var(--primary)';
            toggleBtn.style.color = 'white';
            toggleBtn.style.border = 'none';
            toggleBtn.style.borderRadius = '50%';
            toggleBtn.style.width = '40px';
            toggleBtn.style.height = '40px';
            toggleBtn.style.display = 'none';
            toggleBtn.style.justifyContent = 'center';
            toggleBtn.style.alignItems = 'center';
            toggleBtn.style.cursor = 'pointer';
            
            document.body.appendChild(toggleBtn);
            
            function checkScreenSize() {
                if (window.innerWidth <= 576) {
                    toggleBtn.style.display = 'flex';
                } else {
                    toggleBtn.style.display = 'none';
                    sidebar.classList.remove('active');
                }
            }
            
            toggleBtn.addEventListener('click', function() {
                sidebar.classList.toggle('active');
            });
            
            window.addEventListener('resize', checkScreenSize);
            checkScreenSize();
        });
    </script>
</body>
</html>
