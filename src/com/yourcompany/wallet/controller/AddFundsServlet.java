package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.dao.UserDAO;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AddFundsServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("pages/login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        double amount = Double.parseDouble(request.getParameter("amount"));

        UserDAO dao = new UserDAO();
        boolean success = dao.addFunds(userId, amount);

        if (success) {
            // Store updated user and balance in session for redirect
            double newBalance = dao.getUserBalance(userId);
            com.yourcompany.wallet.model.User user = dao.getUserById(userId);
            session.setAttribute("user", user);
            session.setAttribute("balance", newBalance);

            // Redirect to dashboard JSP (URL will be /pages/dashboard.jsp)
            response.sendRedirect("pages/dashboard.jsp");
        } else {
            request.setAttribute("error", "Failed to add funds");
            request.getRequestDispatcher("pages/add-funds.jsp").forward(request, response);
        }
    }
    
}
