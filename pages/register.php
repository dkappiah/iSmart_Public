<?php
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
  <title>Register - iSmart Bank</title>
  <link rel="icon" href="../assets/img/ismart.png" type="image/x-icon">
  <link rel="stylesheet" href="../pages/dashboard/css/index/home.css">
</head>

<body>
  
  <header>
    <nav class="navbar">
      <div class="logo">
        <img src="../assets/img/ismart.png" alt="iSmart Bank Logo">
        iSmart Bank
      </div>
      <div class="nav-links">
        <a href="home.php">Home</a>
        <a href="login.php" class="btn">Login</a>
      </div>
    </nav>
  </header>

  <section class="hero" style="flex-direction: column; text-align: center;">
    <div class="hero-text" style="max-width: 500px; width: 100%;">
      <h1 style="color: var(--primary-dark); font-family: 'Volkhov', serif;">Create Your <span>iSmart</span> Account</h1>
      <p class="section-subtitle">Start banking smart in minutes with secure, simple onboarding.</p>

      <form action="../scripts/register_auth.php" method="POST" style="display: flex; flex-direction: column; gap: 1.2rem; margin-top: 2rem;">
     
        <div>
          <input type="text" name="fullName" id="fullName" placeholder="Full Name" required
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%;">
          <small id="error-fullName" style="color: red;"></small>
        </div>

        <div>
          <input type="text" name="address" id="address" placeholder="Address" required
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%;">
          <small id="error-address" style="color: red;"></small>
        </div>


        <div>
          <input type="email" name="email" id="email" placeholder="Email Address" required
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%;">
          <small id="error-email" style="color: red;"></small>
        </div>

        <div style="position: relative;">
          <input type="password" name="password" id="password" placeholder="Password" required
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%;">
          <i class="fas fa-eye" id="eye-register" style="position: absolute; top: 50%; right: 1rem; transform: translateY(-50%); cursor: pointer; color: var(--text-light);"></i>
          <small id="error-password" style="color: red;"></small>
        </div>

        <div style="position: relative;">
          <input type="password" id="confirm-password" placeholder="Confirm Password" required
            style="padding: 0.9rem 1rem; font-size: 1rem; border-radius: 12px; border: 1px solid #ccc; width: 100%;">
          <i class="fas fa-eye" id="eye-confirm" style="position: absolute; top: 50%; right: 1rem; transform: translateY(-50%); cursor: pointer; color: var(--text-light);"></i>
          <small id="error-confirmPassword" style="color: red;"><?php echo $error ?></small>
        </div>

       
        <button type="submit" name="submit" class="btn">Create Account</button>
      </form>

      <p style="margin-top: 1.5rem; font-size: 0.9rem; color: var(--text-light);">
        Already have an account? <a href="login.php" style="color: var(--primary); font-weight: 600;">Login</a>
      </p>
    </div>

  
  </section>

 


  <script>
  /**
   * toggle visibility of password input fields using eye icons
   */
  const eyeRegister = document.getElementById('eye-register');
  const eyeConfirm = document.getElementById('eye-confirm');
  const passwordInput = document.getElementById('password');
  const confirmPasswordInput = document.getElementById('confirm-password');

  eyeRegister.addEventListener('click', () => togglePasswordVisibility(passwordInput, eyeRegister));
  eyeConfirm.addEventListener('click', () => togglePasswordVisibility(confirmPasswordInput, eyeConfirm));

  /**
   * switch between password and text input type
   * also updates the eye icon to show current state
   *
   * @param {HTMLInputElement} input the password input field
   * @param {HTMLElement} icon the eye icon element
   */
  function togglePasswordVisibility(input, icon) {
    const type = input.type === 'password' ? 'text' : 'password';
    input.type = type;
    icon.classList.toggle('fa-eye');
    icon.classList.toggle('fa-eye-slash');
  }

  /**
   * validate form inputs before submission
   * check required fields and input formats
   * show errors and prevent form from submitting if invalid
   */
  document.querySelector('form').addEventListener('submit', function(e) {
    let valid = true;

    const fullName = document.getElementById('fullName');
    const address = document.getElementById('address');
    const email = document.getElementById('email');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirm-password');

    // validate full name
    if (!fullName.value.trim()) {
      document.getElementById('error-fullName').textContent = 'Full name is required';
      valid = false;
    } else {
      document.getElementById('error-fullName').textContent = '';
    }

    // validate address
    if (!address.value.trim()) {
      document.getElementById('error-address').textContent = 'Address is required';
      valid = false;
    } else {
      document.getElementById('error-address').textContent = '';
    }

    // validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email.value.trim()) {
      document.getElementById('error-email').textContent = 'Email is required';
      valid = false;
    } else if (!emailRegex.test(email.value)) {
      document.getElementById('error-email').textContent = 'Invalid email format';
      valid = false;
    } else {
      document.getElementById('error-email').textContent = '';
    }

    // validate password length
    if (!password.value.trim()) {
      document.getElementById('error-password').textContent = 'Password is required';
      valid = false;
    } else if (password.value.length < 8) {
      document.getElementById('error-password').textContent = 'Minimum 8 characters required';
      valid = false;
    } else {
      document.getElementById('error-password').textContent = '';
    }

    // validate confirm password match
    if (!confirmPassword.value.trim()) {
      document.getElementById('error-confirmPassword').textContent = 'Confirm your password';
      valid = false;
    } else if (confirmPassword.value !== password.value) {
      document.getElementById('error-confirmPassword').textContent = 'Passwords do not match';
      valid = false;
    } else {
      document.getElementById('error-confirmPassword').textContent = '';
    }

    if (!valid) e.preventDefault();
  });
</script>

</body>
</html>
