package com.capgemini.main;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please enter email and password");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=Database connection failed.");
                return;
            }

            String sql = "SELECT id, name FROM users WHERE email = ? AND password = ?";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, email);
            pst.setString(2, password);  // ✅ Plain password (no hashing)

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("id");
                String userName = rs.getString("name");

                HttpSession session = request.getSession(true);
                session.setAttribute("user_id", String.valueOf(userId)); // Ensure it's stored as a String
                session.setAttribute("user_name", userName);
                session.setMaxInactiveInterval(30 * 60); // 30 minutes

                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            } else {
            	request.setAttribute("loginFailed", true);
            	RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
            	rd.forward(request, response);
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=Invalid email or password");
            }

            rs.close();
            pst.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Something went wrong. Please try again.");
        }
    }
}
