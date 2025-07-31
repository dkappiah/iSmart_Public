package com.yourcompany.wallet.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String resetLink = "http://localhost:8080/juma_wallet/pages/reset-password.jsp?email=" + email;        // Email config
        final String fromEmail = "agyei.emmanuel.bk@gmail.com"; // Replace with your email
        final String password = "coaa tblw shid hazj";       // Use App Password or generated token

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(fromEmail, "Mini Wallet"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            msg.setSubject("Reset Your Password");
            msg.setContent("<p>Click below to reset your password:</p><a href='" + resetLink + "'>Reset Password</a>",
                    "text/html");

            Transport.send(msg);
            request.setAttribute("message", "Reset link has been sent to your email.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Failed to send reset link. Please try again.");
        }

        request.getRequestDispatcher("pages/forgot-password.jsp").forward(request, response);
    }
}
