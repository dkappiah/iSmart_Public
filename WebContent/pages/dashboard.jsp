<%@ page contentType="text/html;charset=UTF-8" %> <% if (session == null ||
session.getAttribute("userId") == null) { response.sendRedirect("login.jsp");
return; } %>

<html>
  <head>
    <title>Dashboard</title>
    <link rel="stylesheet" href="../css/style.css" />
  </head>
  <body>
    <div class="container">
      <% com.yourcompany.wallet.model.User user =
      (com.yourcompany.wallet.model.User) session.getAttribute("user"); Double
      balance = (Double) session.getAttribute("balance"); %>
      <h2>Hello, <%= user != null ? user.getUsername() : "User" %></h2>
      <p>
        <strong>Wallet Balance:</strong> $<%= balance != null ?
        String.format("%.2f", balance) : "0.00" %>
      </p>

      <div class="nav-buttons">
        <a href="add-funds.jsp">➕ Add Funds</a> |
        <a href="transfer.jsp">🔁 Transfer Funds</a> |
        <a href="<%= request.getContextPath() %>/HistoryServlet"
          >📜 Transaction History</a
        >
        |
        <a href="<%= request.getContextPath() %>/LogoutServlet">🚪 Logout</a>
      </div>
    </div>
    <%@ include file="../partials/footer.jsp" %>
  </body>
</html>
