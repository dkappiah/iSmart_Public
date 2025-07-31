package com.yourcompany.wallet.controller;

import com.yourcompany.wallet.dao.UserDAO;
import com.yourcompany.wallet.model.User;
import com.yourcompany.wallet.util.HashUtil;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = HashUtil.sha256(request.getParameter("password"));

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userId", user.getId());
            session.setAttribute("balance", user.getBalance());

            response.sendRedirect("pages/dashboard.jsp");
        } else {
            HttpSession session = request.getSession();
            session.setAttribute("loginError", "Invalid credentials");
            response.sendRedirect("pages/login.jsp");
        }
    }
}
 