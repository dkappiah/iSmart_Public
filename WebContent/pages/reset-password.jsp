<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="../partials/header.jsp" %>
<html>
<head>
    <title>Reset Password</title>
    <link rel="stylesheet" href="../css/style.css" />
</head>
<body>
<div class="container">
    <h2>Reset Your Password</h2>

    <form action="../ResetPasswordServlet" method="post">
        <input type="hidden" name="email" value="<%= request.getParameter("email") %>" />
        
        <label for="password">New Password:</label><br />
        <input type="password" name="password" required><br />

        <label for="confirm">Confirm Password:</label><br />
        <input type="password" name="confirm" required><br />

        <button type="submit">Reset Password</button>
    </form>

    <% String msg = (String) request.getAttribute("msg");
       if (msg != null) { %>
        <div class="info-box"><%= msg %></div>
    <% } %>
</div>
<%@ include file="../partials/footer.jsp" %>
</body>
</html>
