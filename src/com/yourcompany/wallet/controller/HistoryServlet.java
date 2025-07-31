package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.dao.UserDAO;
import com.yourcompany.wallet.model.Transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/HistoryServlet")
public class HistoryServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        List<Transaction> transactions = new UserDAO().getTransactionsForUser(userId);
        request.setAttribute("transactions", transactions);

        request.getRequestDispatcher("pages/history.jsp").forward(request, response);
    }
}