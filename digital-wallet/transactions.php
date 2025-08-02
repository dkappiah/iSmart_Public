<?php
session_start();
require_once 'inc/db_connect.php';

//Redirect to login page if the user is not logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

//Fetching transactions for the current user
$stmt = $pdo->prepare("
    SELECT 
        t.*, 
        u.username AS recipient_name 
    FROM transactions t
    LEFT JOIN users u ON t.reference_user = u.id
    WHERE t.user_id = ?
    ORDER BY t.created_at DESC
");
$stmt->execute([$_SESSION['user_id']]);
$transactions = $stmt->fetchAll();
?>

<?php include 'inc/header.php'; ?>
<h2>Your Transaction History</h2>

<!--Checking if the user has made any transactions-->
<?php if (count($transactions) === 0): ?>
    <p>You have no transactions yet.</p>
<?php else: ?>
    <!--Table displaying all the transactions of the current user-->
    <table class="transactions">
        <thead>
            <tr>
                <th>Date</th>
                <th>Type</th>
                <th>Amount (GHS)</th>
                <th>Status</th>
                <th>Recipient</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($transactions as $tx): ?>
            <tr>
                <td><?= date('Y-m-d H:i', strtotime($tx['created_at'])) ?></td>
                <td><?= ucfirst($tx['type']) ?></td>
                <td><?= number_format($tx['amount'], 2) ?></td>
                <td><?= ucfirst($tx['status']) ?></td>
                <td><?= $tx['type'] === 'transfer' ? htmlspecialchars($tx['recipient_name']) : '-' ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>
