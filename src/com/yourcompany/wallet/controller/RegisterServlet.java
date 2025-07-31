package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.model.User;
import com.yourcompany.wallet.dao.UserDAO;
import com.yourcompany.wallet.util.HashUtil;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String passwordRaw = request.getParameter("password");
        String confirm = request.getParameter("confirm");

        boolean passwordMismatch = !passwordRaw.equals(confirm);
        boolean emailExists = false;
        boolean usernameExists = false;

        UserDAO dao = new UserDAO();
        // Check if email exists
        if (dao.emailExists(email)) {
            emailExists = true;
        }
        // Check if username exists (add this method to UserDAO if not present)
        try {
            String sql = "SELECT id FROM users WHERE username = ?";
            try (Connection conn = com.yourcompany.wallet.util.DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, username);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    usernameExists = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (passwordMismatch) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("pages/register.jsp").forward(request, response);
            return;
        }

        if (emailExists || usernameExists) {
            request.setAttribute("error", "Username or email is already taken.");
            request.getRequestDispatcher("pages/register.jsp").forward(request, response);
            return;
        }

        String password = com.yourcompany.wallet.util.HashUtil.sha256(passwordRaw);

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password);

        if (dao.register(user)) {
            // Registration successful, redirect to login page
            response.sendRedirect("pages/login.jsp");
        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("pages/register.jsp").forward(request, response);
        }
    }
}