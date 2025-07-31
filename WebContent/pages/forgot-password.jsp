<%@ page contentType="text/html;charset=UTF-8" %> <%@ include
file="../partials/header.jsp" %>
<html>
  <head>
    <title>Forgot Password</title>
    <link rel="stylesheet" href="../css/style.css" />
  </head>
  <body>
    <div class="container">
      <h2>Forgot Your Password?</h2>

      <form action="../ForgotPasswordServlet" method="post">
        <label for="email">Enter your email address:</label><br />
        <input type="email" name="email" required /><br />
        <button type="submit">Send Reset Link</button>
      </form>

      <p>Back to <a href="login.jsp">Login</a></p>

      <% String message = (String) request.getAttribute("message"); if (message
      != null) { %>
      <script>
        alert("<%= message %>");
      </script>
      <div class="info-box"><%= message %></div>
      <% } %>
    </div>
    <%@ include file="../partials/footer.jsp" %>
  </body>
</html>
