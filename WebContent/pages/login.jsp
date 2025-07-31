<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // If user is already logged in, redirect to dashboard
    if (session != null && session.getAttribute("userId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<%@ include file="../partials/header.jsp" %>
<html>
  <head>
    <title>Login - Digital Wallet</title>
    <link rel="stylesheet" href="../css/style.css" />
  </head>
  <body>
    <div class="container">
      <% String logoutSuccess = request.getParameter("logout"); if
      ("success".equals(logoutSuccess)) { %>
      <div class="info-box">✅ You have been logged out successfully.</div>
      <% } %> <% String loginError = null; if
      (session.getAttribute("loginError") != null) { loginError = (String)
      session.getAttribute("loginError"); session.removeAttribute("loginError");
      } %> <% if (loginError != null) { %>
      <div class="error-box"><%= loginError %></div>
      <script>
        alert("<%= loginError %>");
      </script>
      <% } %>
      <h2>Login</h2>
      <form action="../LoginServlet" method="post">
        <label>Email:</label><br />
        <input type="email" name="email" required /><br />

        <label>Password:</label><br />
        <input type="password" name="password" required /><br />

        <button type="submit">Login</button>
      </form>

      <p class="form-link">
        Don't have an account?
        <a href="register.jsp" class="form-link-a">Register here</a>
      </p>
      <p class="form-link">
        <a href="forgot-password.jsp" class="btn form-link-a"
          >Forgot password?</a
        >
      </p>
    </div>

    <%@ include file="../partials/footer.jsp" %>
  </body>
</html>
