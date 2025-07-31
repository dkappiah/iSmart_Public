<%@ page contentType="text/html;charset=UTF-8" %>
<% if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
} %>
<%@ include file="../partials/header.jsp" %>
<!-- ...rest of your transfer code... -->

<html>
  <head>
    <title>Transfer Funds</title>
    <link rel="stylesheet" href="../css/style.css" />
  </head>
  <body>
    <div class="container">
      <h2>Transfer Funds</h2>
      <% String error = (String) request.getAttribute("error"); if (error !=
      null) { %>
      <div class="error-box"><%= error %></div>
      <% } %>
      <form action="../TransferServlet" method="post">
        <div class="form-group">
          <label for="recipient">Recipient Username</label>
          <input
            type="text"
            id="recipient"
            name="recipient"
            pattern=".{3,}"
            required
            placeholder="Enter recipient username"
          />
        </div>
        <div class="form-group">
          <label for="amount">Amount</label>
          <input
            type="number"
            id="amount"
            name="amount"
            min="1"
            step="0.01"
            required
            placeholder="Enter amount"
          />
        </div>
        <button type="submit">Transfer</button>
      </form>
      <a class="back-link" href="dashboard.jsp">&larr; Back to Dashboard</a>
      <a href="<%= request.getContextPath() %>/LogoutServlet" class="btn-logout"
        >Logout</a
      >
    </div>
    <%@ include file="../partials/footer.jsp" %>
    <script src="../js/validate.js"></script>
  </body>
</html>
