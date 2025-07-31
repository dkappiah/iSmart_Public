package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirm");

        if (!password.equals(confirm)) {
            request.setAttribute("msg", "Passwords do not match.");
            request.getRequestDispatcher("pages/reset-password.jsp").forward(request, response);
            return;
        }

        // Hash the password before saving
        String hashedPassword = com.yourcompany.wallet.util.HashUtil.sha256(password);
        boolean updated = new UserDAO().updatePasswordByEmail(email, hashedPassword);

        if (updated) {
            request.setAttribute("msg", "Password successfully updated. Please login.");
            response.sendRedirect("pages/login.jsp");
        } else {
            request.setAttribute("msg", "Error updating password.");
            request.getRequestDispatcher("pages/reset-password.jsp").forward(request, response);
        }
    }
}
