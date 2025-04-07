package com.capgemini.main;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AddMoneyServlet")
public class AddMoneyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = Integer.parseInt(session.getAttribute("user_id").toString());

        double amount = Double.parseDouble(request.getParameter("amount"));

        String dbURL = "jdbc:mysql://localhost:3306/movie_booking";
        String dbUser = "root";
        String dbPass = "1234";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            String checkSql = "SELECT * FROM wallet WHERE user_id = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, userId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                String updateSql = "UPDATE wallet SET balance = balance + ? WHERE user_id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setDouble(1, amount);
                updateStmt.setInt(2, userId);
                updateStmt.executeUpdate();
                updateStmt.close();
            } else {
                String insertSql = "INSERT INTO wallet (user_id, balance) VALUES (?, ?)";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                insertStmt.setInt(1, userId);
                insertStmt.setDouble(2, amount);
                insertStmt.executeUpdate();
                insertStmt.close();
            }

            rs.close();
            checkStmt.close();
            conn.close();

            // Set flag for success popup
            session.setAttribute("moneyAdded", true);

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("dashboard.jsp");
    }
}
