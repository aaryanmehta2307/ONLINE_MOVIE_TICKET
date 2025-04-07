package com.capgemini.main;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = Integer.parseInt(session.getAttribute("user_id").toString());
        String selectedSeats = (String) session.getAttribute("selectedSeats");

        if (selectedSeats == null || selectedSeats.isEmpty()) {
            updatePaymentStatus(userId, selectedSeats, "Failed");
            response.sendRedirect("payment_status.jsp?status=failed&error=InvalidSeats");
            return;
        }

        double totalPrice = Double.parseDouble(session.getAttribute("totalPrice").toString());
        String paymentMethod = request.getParameter("paymentMethod");

        String dbURL = "jdbc:mysql://localhost:3306/movie_booking";
        String dbUser = "root";
        String dbPass = "1234";

        boolean paymentSuccess = false;

        try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
            if ("wallet".equals(paymentMethod)) {
                String balanceQuery = "SELECT balance FROM wallet WHERE user_id = ?";
                try (PreparedStatement balanceStmt = conn.prepareStatement(balanceQuery)) {
                    balanceStmt.setInt(1, userId);
                    ResultSet rs = balanceStmt.executeQuery();

                    if (!rs.next()) {
                        updatePaymentStatus(userId, selectedSeats, "Failed");
                        response.sendRedirect("payment_status.jsp?status=failed&error=NoWalletEntry");
                        return;
                    }

                    BigDecimal walletBalance = rs.getBigDecimal("balance");
                    BigDecimal ticketPrice = BigDecimal.valueOf(totalPrice);

                    if (walletBalance.compareTo(ticketPrice) >= 0) {
                        // Deduct balance
                        String deductQuery = "UPDATE wallet SET balance = balance - ? WHERE user_id = ?";
                        try (PreparedStatement deductStmt = conn.prepareStatement(deductQuery)) {
                            deductStmt.setBigDecimal(1, ticketPrice);
                            deductStmt.setInt(2, userId);
                            deductStmt.executeUpdate();
                        }

                        // Update booking status to Completed
                        updatePaymentStatus(userId, selectedSeats, "Completed");
                        paymentSuccess = true;
                    } else {
                        updatePaymentStatus(userId, selectedSeats, "Failed");
                        response.sendRedirect("payment_status.jsp?status=failed&error=InsufficientFunds");
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            updatePaymentStatus(userId, selectedSeats, "Failed");
            response.sendRedirect("payment_status.jsp?status=failed&error=DatabaseError");
            return;
        }

        response.sendRedirect("payment_status.jsp?status=" + (paymentSuccess ? "success" : "failed"));
    }

    private void updatePaymentStatus(int userId, String selectedSeats, String status) {
        String dbURL = "jdbc:mysql://localhost:3306/movie_booking";
        String dbUser = "root";
        String dbPass = "1234";

        String updateQuery = "UPDATE bookings SET payment_status = ? WHERE user_id = ? AND seats = ?";

        try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
             PreparedStatement stmt = conn.prepareStatement(updateQuery)) {

            stmt.setString(1, status);
            stmt.setInt(2, userId);
            stmt.setString(3, selectedSeats);
            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
