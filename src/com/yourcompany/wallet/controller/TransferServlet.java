package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class TransferServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("pages/login.jsp");
            return;
        }
        int userId = (int) session.getAttribute("userId");
        String recipient = request.getParameter("recipient");
        String amountStr = request.getParameter("amount");
        double amount = 0.0;
        try {
            amount = Double.parseDouble(amountStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid amount.");
            request.getRequestDispatcher("pages/transfer.jsp").forward(request, response);
            return;
        }
        UserDAO dao = new UserDAO();
        boolean success = dao.transferFunds(userId, recipient, amount);
        if (success) {
            // Store updated user and balance in session for redirect
            double freshBalance = dao.getUserBalance(userId);
            com.yourcompany.wallet.model.User user = dao.getUserById(userId);
            session.setAttribute("user", user);
            session.setAttribute("balance", freshBalance);

            // Redirect to dashboard JSP (URL will be /pages/dashboard.jsp)
            response.sendRedirect("pages/dashboard.jsp");
        } else {
            request.setAttribute("error", "Transfer failed. Please check recipient and balance.");
            request.getRequestDispatcher("pages/transfer.jsp").forward(request, response);
        }
    }
}
