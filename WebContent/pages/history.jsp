<%@ page contentType="text/html;charset=UTF-8" %> <%@ page
import="java.util.List, com.yourcompany.wallet.model.Transaction" %> <% if
(session == null || session.getAttribute("userId") == null) {
response.sendRedirect("login.jsp"); return; } List<Transaction>
  transactions = (List<Transaction
    >) request.getAttribute("transactions"); if (transactions == null) {
    transactions = java.util.Collections.emptyList(); } %> <%@ include
    file="../partials/header.jsp" %>

    <html>
      <head>
        <title>Transaction History</title>
        <link rel="stylesheet" href="../css/style.css" />
      </head>
      <body>
        <div class="container">
          <h2>Transaction History</h2>

          <% if (transactions.isEmpty()) { %>
          <p>No transactions found.</p>
          <% } else { %>
          <table border="1" cellpadding="8" cellspacing="0">
            <tr>
              <th>Date</th>
              <th>Type</th>
              <th>Amount</th>
              <th>Status</th>
              <th>Related User</th>
            </tr>
            <% for (Transaction t : transactions) { %>
            <tr>
              <td><%= t.getDate() %></td>
              <td><%= t.getType() %></td>
              <td>$<%= t.getAmount() %></td>
              <td><%= t.getStatus() %></td>
              <td>
                <%= t.getRelatedUser() != null ? t.getRelatedUser() : "-" %>
              </td>
            </tr>
            <% } %>
          </table>
          <% } %>
        </div>
        <a
          href="<%= request.getContextPath() %>/LogoutServlet"
          class="btn-logout"
          >Logout</a
        >
        <%@ include file="../partials/footer.jsp" %>
      </body>
    </html>
  </Transaction></Transaction
>
