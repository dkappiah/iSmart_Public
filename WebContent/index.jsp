<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ include
file="partials/header.jsp" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Mini Wallet – Home</title>
    <link rel="stylesheet" href="css/style.css" />
  </head>
  <body>
    <header class="main-header">
      <div class="nav-container">
        <div class="logo">
          <h1>💳 Mini Wallet</h1>
        </div>
        <nav class="nav-menu">
          <a href="index.jsp" class="active">Home</a>
          <a href="pages/about.jsp">About</a>
          <a href="pages/contact.jsp">Contact</a>
          <a href="pages/login.jsp">Login</a>
          <a href="pages/register.jsp">Register</a>
        </nav>
      </div>
    </header>

    <main class="home-content">
      <section>
        <h2>Welcome to Mini Wallet 💼</h2>
        <p>Your simple and secure way to manage digital funds.</p>
        <p>Register an account or log in to get started.</p>
        <a href="pages/register.jsp" class="btn">Get Started</a>
      </section>
    </main>

    <footer class="main-footer">
      <p>&copy; 2025 Mini Wallet. All rights reserved.</p>
    </footer>
  </body>
</html>
