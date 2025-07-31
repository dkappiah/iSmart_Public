package com.yourcompany.wallet.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false); // don't create if not exists
        if (session != null) {
            session.invalidate(); // destroy session
        }

        // Redirect with logout flag
        response.sendRedirect("pages/login.jsp?logout=success");
    }
}
