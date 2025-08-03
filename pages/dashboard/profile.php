<?php
session_start();
if (!isset($_SESSION['AccNo'])) {
    header('Location: ../login.php?msg=Please login to continue');
    exit;
}

require('../../configs/db.php');
require('../../scripts/get_userinfo.php'); // $All user info
require('pp_check.php'); // PP Check
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - iSmart Bank</title>
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
                    <li class="nav-item active">
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
                <div class="search-box">
                 
                </div>
                
                <div class="nav-icons">
                    <a href="#">
                       
                    </a>
                    <a href="#">
                        
                    </a>
                    <div class="user-profile">
                        <div class="user-avatar" style="background-image: url(<?php echo $pp ?>);"></div>
                        <span class="user-name"><?php echo $name ?></span>
                    </div>
                </div>
            </header>

            <!-- Profile Content -->
            <div class="dashboard-content">
                <div class="welcome-header">
                    <h1>Your Profile</h1>
                    <p>Manage your personal information and account details</p>
                </div>

                <div class="content-grid">
                    <!-- Profile Picture Section -->
                    <div class="transactions-card">
                        <div class="card-header">
                            <h2 class="card-title">Profile Picture</h2>
                        </div>
                        <div class="profile-picture-container" style="text-align: center; padding: 2rem;">
                            <img src="<?php echo $pp ?>" alt="Profile Picture" style="width: 150px; height: 150px; border-radius: 50%; object-fit: cover; border: 4px solid var(--primary);">
                            <div style="margin-top: 1rem;">
                                <p class="stat-card-title"><?php echo $accNo ?></p>
                                <p class="stat-card-footer">Saving Account</p>
                                <p class="stat-card-footer">iSmart Bank Ltd</p>
                            </div>
                        </div>
                    </div>

                    <!-- Account Information Section -->
                    <div class="transfer-card">
                        <div class="card-header">
                            <h2 class="card-title">Account Information</h2>
                            <a href="settings.php" class="btn" style="padding: 0.5rem 1rem; font-size: 0.8rem;">
                                <i class="fas fa-edit"></i> Edit Profile
                            </a>
                        </div>
                        
                        <div style="padding: 1rem;">
                            <div class="form-group">
                                <label class="form-label"><strong>Account Number:</strong></label>
                                <div class="form-control" style="background-color: var(--light); border: none;">
                                    <?php echo $accNo ?>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label"><strong>Account Type:</strong></label>
                                <div class="form-control" style="background-color: var(--light); border: none;">
                                    Saving Account
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label"><strong>Full Name:</strong></label>
                                <div class="form-control" style="background-color: var(--light); border: none;">
                                    <?php echo $name ?>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label"><strong>Address:</strong></label>
                                <div class="form-control" style="background-color: var(--light); border: none;">
                                    <?php echo $address ?>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label"><strong>Email:</strong></label>
                                <div class="form-control" style="background-color: var(--light); border: none;">
                                    <?php echo $email ?>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    
</body>
</html>