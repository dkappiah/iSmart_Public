<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Digital Wallet</title>
    
    <!--Link to the custom stylesheet-->
    <link rel="stylesheet" href="styles/style.css">
    
    <!--Linkiing Font Awesome for icons-->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>

    <!--Link to js file-->
    <script src="scripts/script.js" defer></script>

    <!--Linking SweetAlert2 for alerts-->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
<header>
    <div class="nav-container">
        <div class="logo">
            <img src="assets/logo.png" id="logo" alt="Wallet Logo">
        </div>

        <!--Button for changing the theme-->
        <button id="theme-toggle" class="theme-toggle">🌓</button>
        
        <!--Navigation menu only shows if $hideNav is not set or false (so navbar doesn't show on login and register pages-->
        <?php if (!isset($hideNav) || !$hideNav):
        $current_page = basename($_SERVER['PHP_SELF']);?>
        
        <!--Navbar for easy navigation-->
        <nav>
            <a href="dashboard.php" class="<?= $current_page == 'dashboard.php' ? 'active' : '' ?>">
            <i class="fa-solid fa-chart-line"></i>Dashboard</a> |
            
            <a href="add_funds.php" class="<?= $current_page == 'add_funds.php' ? 'active' : '' ?>">
            <i class="fa-solid fa-wallet"></i>Add Funds</a> |
            
            <a href="transfer.php" class="<?= $current_page == 'transfer.php' ? 'active' : '' ?>">
            <i class="fa-solid fa-money-bill-transfer"></i>Transfer</a> |
            
            <a href="transactions.php" class="<?= $current_page == 'transactions.php' ? 'active' : '' ?>">
            <i class="fa-solid fa-comments-dollar"></i>Transactions</a> |
            
            <a href="change_password.php" class="<?= $current_page == 'change_password.php' ? 'active' : '' ?>">
            <i class="fa-solid fa-key"></i>Change Password</a> |

            <a href="logout.php">Logout</a>
        </nav>
        <?php endif; ?>
    </div>
</header>
<main>
