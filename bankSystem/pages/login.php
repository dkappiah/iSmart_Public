<?php
session_start();
if (isset($_SESSION['AccNo'])) {
    header('Location: ../pages/dashboard/index.php');
    exit;
}

$error = '';
if (isset($_GET['msg'])) {
    $error = $_GET['msg'];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login - iSmart Bank</title>
  <link rel="icon" href="../assets/img/ismart.png" type="image/x-icon">
  <link rel="stylesheet" href="../pages/dashboard/css/index/home.css">
 
</head>

<body>
  <!-- Header -->
  <header>
    <nav class="navbar">
      <div class="logo">
        <img src="../assets/img/ismart.png" alt="iSmart Bank Logo">
        iSmart Bank
      </div>
      <div class="nav-links">
        <a href="home.php">Home</a>
        <a href="register.php" class="btn">Sign Up</a>
      </div>
    </nav>
  </header>

  <!-- Login Section -->
  <section class="hero" style="flex-direction: column; text-align: center;">
    <div class="hero-text" style="max-width: 420px; width: 100%;">
      <h1 style="color: var(--primary-dark); font-family: 'Volkhov', serif;">Welcome Back to <span>iSmart</span></h1>
      <p class="section-subtitle">Smart, secure banking — right at your fingertips.</p>

      <form action="../scripts/login_auth.php" method="POST" style="display: flex; flex-direction: column; gap: 1.2rem; margin-top: 2rem;">
        <!-- Account Number -->
        <div>
          <input 
            type="text" 
            name="accountNumber" 
            id="accountNumber" 
            placeholder="Account Number" 
            required 
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%; font-family: 'Poppins', sans-serif;"
          >
          <small id="error-accountNumber" style="color: red;"></small>
        </div>

        <!-- Password -->
        <div style="position: relative;">
          <input 
            type="password" 
            name="password" 
            id="password" 
            placeholder="Password" 
            required 
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%; font-family: 'Poppins', sans-serif;"
          >
          <i class="fas fa-eye" id="eye-login" style="position: absolute; top: 50%; right: 1rem; transform: translateY(-50%); color: var(--text-light); cursor: pointer;"></i>
          <small id="error-password" style="color: red;"><?php echo $error ?></small>
        </div>

        <!-- Login Button -->
        <button type="submit" name="submit" class="btn">Login</button>
      </form>

      <!-- Register Link -->
      <p style="margin-top: 1.5rem; font-size: 0.9rem; color: var(--text-light);">
        Don’t have an account? 
        <a href="register.php" style="color: var(--primary); font-weight: 600;">Register</a>
      </p>
    </div>

    
  </section>



  <!-- Scripts -->
  <script>
    const eyeIcon = document.getElementById('eye-login');
    const passwordInput = document.getElementById('password');

    eyeIcon.addEventListener('click', () => {
      const type = passwordInput.getAttribute('type');
      passwordInput.setAttribute('type', type === 'password' ? 'text' : 'password');
      eyeIcon.classList.toggle('fa-eye-slash');
      eyeIcon.classList.toggle('fa-eye');
    });

    document.querySelector('form').addEventListener('submit', function(e) {
      let valid = true;

      const acc = document.getElementById('accountNumber');
      const pass = document.getElementById('password');

      if (!acc.value.trim()) {
        document.getElementById('error-accountNumber').textContent = 'Account number is required';
        valid = false;
      } else {
        document.getElementById('error-accountNumber').textContent = '';
      }

      if (!pass.value.trim()) {
        document.getElementById('error-password').textContent = 'Password is required';
        valid = false;
      }

      if (!valid) e.preventDefault();
    });
  </script>
</body>
</html>
