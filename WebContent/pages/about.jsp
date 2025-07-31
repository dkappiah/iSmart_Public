<%@ page contentType="text/html;charset=UTF-8" %>
<!-- <% if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
} %> -->
<%@ include file="../partials/header.jsp" %>
<!-- ...rest of your contact/about code... -->
<html>
  <head>
    <title>About</title>
  </head>
  <body>
    <h2>About Mini Wallet</h2>
    <p>
      This app simulates basic wallet operations like sending and receiving
      funds.
    </p>
    <a href="<%= request.getContextPath() %>/LogoutServlet" class="btn-logout"
      >Logout</a
    >
  </body>
</html>
