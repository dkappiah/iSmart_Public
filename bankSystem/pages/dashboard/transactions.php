<?php
session_start();
if (!isset($_SESSION['AccNo'])) {
    header('Location: ../login.php?msg=Please login to continue');
    exit;
}

require('../../configs/db.php');
require('pp_check.php'); // PP Check
require('../../scripts/get_userinfo.php'); // $fName, $accNo

// Get transactions and account names
$trns = [];
$query = "SELECT t.*, u1.Name as SenderName, u2.Name as ReceiverName 
          FROM transactions t
          LEFT JOIN userinfo u1 ON t.Sender = u1.AccNo
          LEFT JOIN userinfo u2 ON t.Receiver = u2.AccNo
          WHERE t.Sender = '$accNo' OR t.Receiver = '$accNo'
          ORDER BY t.DateTime DESC";
$result = mysqli_query($conn, $query);
while ($row = mysqli_fetch_assoc($result)) {
    $trns[] = $row;
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transactions - iSmart Bank</title>
    <link rel="icon" href="../../assets/img/ismart.png" type="image/x-icon">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="../../pages/dashboard/css/index/Dashboard.css">
    
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
                    <li class="nav-item">
                        <a href="./transfer.php" class="nav-link">
                            <i class="fas fa-exchange-alt"></i>
                            <span>Transfer</span>
                        </a>
                    </li>
                    <li class="nav-item active">
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
            <!-- Top Navigation - Simplified -->
            <header class="top-nav">
                <div class="user-profile" style="margin-left: auto;">
                    <div class="user-avatar" style="background-image: url(<?php echo $pp ?>);"></div>
                    <span class="user-name"><?php echo $name ?></span>
                </div>
            </header>

            <!-- Transactions Content -->
            <div class="dashboard-content">
                <div class="welcome-header">
                    <h1>Transaction History</h1>
                    <p>View all your account transactions</p>
                </div>

                <div class="transactions-card" style="margin-top: 2rem;">
                    <div class="card-header">
                        <h2 class="card-title">All Transactions</h2>
                    </div>
                    
                    <div class="table-responsive" style="overflow-x: auto;">
                        <table class="transactions-table">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Description</th>
                                    <th>Amount</th>
                                    <th>Remarks</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                foreach ($trns as $trn) {
                                    $date = date('d-m-Y H:i', strtotime($trn['DateTime']));
                                    $amount = $trn['Amount'];
                                    $remarks = $trn['Remarks'];
                                    
                                    if ($trn['Sender'] == 0) {
                                        // Top-up transaction
                                        echo "<tr>
                                            <td><span class='transaction-type credit'>Credit</span></td>
                                            <td>Top-up to your account</td>
                                            <td class='transaction-amount'>+ GHc " . number_format($amount, 2) . "</td>
                                            <td>$remarks</td>
                                            <td>$date</td>
                                        </tr>";
                                    } elseif ($trn['Receiver'] == $accNo) {
                                        // Received money
                                        $senderName = $trn['SenderName'] ?? 'System';
                                        echo "<tr>
                                            <td><span class='transaction-type credit'>Credit</span></td>
                                            <td>Transfer from $senderName</td>
                                            <td class='transaction-amount'>+ GHc " . number_format($amount, 2) . "</td>
                                            <td>$remarks</td>
                                            <td>$date</td>
                                        </tr>";
                                    } elseif ($trn['Sender'] == $accNo) {
                                        // Sent money
                                        $receiverName = $trn['ReceiverName'] ?? 'Unknown';
                                        echo "<tr>
                                            <td><span class='transaction-type debit'>Debit</span></td>
                                            <td>Transfer to $receiverName</td>
                                            <td class='transaction-amount'>- GHc " . number_format($amount, 2) . "</td>
                                            <td>$remarks</td>
                                            <td>$date</td>
                                        </tr>";
                                    }
                                }
                                ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    
</body>
</html>