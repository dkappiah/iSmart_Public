package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.dao.UserDAO;
import com.yourcompany.wallet.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class DashboardServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // 🚫 Block unauthenticated access
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userId = (int) session.getAttribute("userId");
        // 🔁 Refresh balance from DB
        UserDAO dao = new UserDAO();
        double freshBalance = dao.getUserBalance(userId);
        session.setAttribute("balance", freshBalance);
        // Set user info for dashboard display
        User user = dao.getUserById(userId);
        request.setAttribute("user", user);
        request.setAttribute("balance", freshBalance);
        // Forward to dashboard page
        request.getRequestDispatcher("pages/dashboard.jsp").forward(request, response);
    }
}
 