package com.capgemini.main;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L; // Best practice to define UID

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // Prevent browser from caching the page
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies

        // Get current session, don't create a new one if it doesn't exist
        HttpSession session = request.getSession(false);

        if (session != null) {
            session.invalidate(); // Invalidate session
            System.out.println("✅ User logged out successfully.");
        } else {
            System.out.println("ℹ️ No active session found during logout.");
        }

        // Redirect to login page
        response.sendRedirect("login.jsp");
    }
}
