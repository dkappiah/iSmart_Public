<?php
session_start();
require_once 'inc/db_connect.php';

//Redirect to login if the user is not logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

//Get the user's current balance from the database
$stmt = $pdo->prepare("SELECT balance FROM users WHERE id = ?");
$stmt->execute([$_SESSION['user_id']]);
$user = $stmt->fetch();
?>

<?php include 'inc/header.php'; ?>
<h2>Welcome, <?= htmlspecialchars($_SESSION['username']) ?>!</h2>

<div class="dashboard-container">

    <!--Wallet balance display-->
    <div class="wallet-card">
        <h3>Current Wallet Balance</h3>
        <p class="balance">GHS <?= number_format($user['balance'], 2) ?></p>

        <!--Actions buttons for wallet operations-->
        <div class="dashboard-actions">
            <a class="button" href="add_funds.php"><i class="fa-solid fa-wallet"></i> Add Funds</a>
            <a class="button" href="transfer.php"><i class="fa-solid fa-money-bill-transfer"></i> Transfer Funds</a>
            <a class="button" href="transactions.php"><i class="fa-solid fa-comments-dollar"></i> View Transactions</a>
        </div>
    </div>

    <!--Transactions preview (table) that shows the 5 most recent transactions -->
    <div class="transactions-preview">
        <h3>Recent Transactions</h3>
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Amount</th>
                </tr>
            </thead>
            <tbody>
                <?php
                //Getting the 5 most recent transactions for the logged-in user
                $stmt = $pdo->prepare("SELECT created_at, type, amount, status, reference_user FROM transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 5");
                $stmt->execute([$_SESSION['user_id']]);
                $recent = $stmt->fetchAll();

                foreach ($recent as $row): ?>
                    <tr>
                        <td><?= date('M j, Y', strtotime($row['created_at'])) ?></td>
                        <td><?= ucfirst($row['type']) ?></td>
                        <td>GHS <?= number_format($row['amount'], 2) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
        <a href="transactions.php" class="view-all">View All →</a>
    </div>

</div>
