<%@ page contentType="text/html;charset=UTF-8" %>
<% if (session == null || session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
} %>
<%@ include file="../partials/header.jsp" %>

<html>
  <head>
    <title>Add Funds</title>
    <link rel="stylesheet" href="../css/style.css" />
    <style>
      .form-group {
        margin-bottom: 1em;
      }
      label {
        font-weight: bold;
        display: block;
        margin-bottom: 0.3em;
      }
      input[type="number"],
      input[type="text"] {
        width: 100%;
        padding: 0.5em;
        border: 1px solid #ccc;
        border-radius: 4px;
        box-sizing: border-box;
      }
      button[type="submit"] {
        background-color: #007bff;
        color: #fff;
        border: none;
        padding: 0.7em 1.5em;
        border-radius: 4px;
        cursor: pointer;
        font-size: 1em;
      }
      button[type="submit"]:hover {
        background-color: #0056b3;
      }
      .container {
        max-width: 400px;
        margin: 2em auto;
        background: #fff;
        padding: 2em;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
      }
      h2 {
        text-align: center;
        margin-bottom: 1.5em;
      }
      .back-link {
        display: block;
        text-align: center;
        margin-top: 1.5em;
        color: #007bff;
        text-decoration: none;
      }
      .back-link:hover {
        text-decoration: underline;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h2>Add Funds</h2>
      <form action="../AddFundsServlet" method="post">
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
        <button type="submit">Add Funds</button>
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
