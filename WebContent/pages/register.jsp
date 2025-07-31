<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../partials/header.jsp" %>

<html>
  <head>
    <title>Register - Digital Wallet</title>
    <link rel="stylesheet" href="../css/style.css" />
    <script>
      function validateForm(event) {
        const username = document.getElementById("username").value.trim();
        const email = document.getElementById("email").value.trim();
        const password = document.getElementById("password").value;
        const confirm = document.getElementById("confirm").value;

        // Check for empty values
        if (!username || !email || !password || !confirm) {
          alert("Please fill in all fields.");
          event.preventDefault();
          return false;
        }

        // Check password match
        if (password !== confirm) {
          alert("Passwords do not match.");
          event.preventDefault();
          return false;
        }

        return true;
      }

      // Attach the validation on page load
      window.onload = function () {
        document.getElementById("registerForm").addEventListener("submit", validateForm);
      };
    </script>
  </head>
  <body>
    <div class="container">
      <h2>Create Your Account</h2>

      <%-- Show backend error if available --%>
      <% String error = (String) request.getAttribute("error");
         if (error != null) { %>
        <div class="error-box">
          <%= error %>
        </div>
      <% } %>

      <form action="../RegisterServlet" method="post" id="registerForm">
        <label for="username">Username:</label><br />
        <input type="text" id="username" name="username" required /><br />

        <label for="email">Email:</label><br />
        <input type="email" id="email" name="email" required /><br />

        <label for="password">Password:</label><br />
        <input type="password" id="password" name="password" required /><br />

        <label for="confirm">Confirm Password:</label><br />
        <input type="password" id="confirm" name="confirm" required /><br />

        <button type="submit">Register</button>
      </form>

      <p>Already have an account? <a href="login.jsp">Login here</a></p>
    </div>

    <%@ include file="../partials/footer.jsp" %>
  </body>
</html>
