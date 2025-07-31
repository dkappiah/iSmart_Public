<%@ page contentType="text/html;charset=UTF-8" %>
<!-- <% if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
} %> -->
<%@ include file="../partials/header.jsp" %>
<!-- ...rest of your contact/about code... -->
<html>
  <head>
    <title>Contact</title>
  </head>
  <body>
    <h2>Contact Us</h2>
    <p>Email: support@miniwallet.com</p>
    <p>Phone: +233 123 456 789</p>
    <a href="<%= request.getContextPath() %>/LogoutServlet" class="btn-logout"
      >Logout</a
    >
  </body>
</html>
