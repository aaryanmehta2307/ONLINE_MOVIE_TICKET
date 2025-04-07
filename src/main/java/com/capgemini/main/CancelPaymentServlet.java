package com.capgemini.main;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CancelPaymentServlet")
public class CancelPaymentServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_booking";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "1234";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user_id") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(session.getAttribute("user_id").toString());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String selectedSeats = request.getParameter("selectedSeats");
        if (selectedSeats == null || selectedSeats.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String updateQuery = "UPDATE bookings SET payment_status = 'Failed' " +
                             "WHERE user_id = ? AND seats = ? AND payment_status = 'Pending'";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement stmt = conn.prepareStatement(updateQuery)) {

            stmt.setInt(1, userId);
            stmt.setString(2, selectedSeats);
            int rowsUpdated = stmt.executeUpdate();

            if (rowsUpdated > 0) {
                // Mark payment failed
                session.setAttribute("paymentStatus", "failed");

                // Clear stale booking details from session to allow new booking
                session.removeAttribute("bookingId");
                session.removeAttribute("bookingInserted");
                session.removeAttribute("movie_id");
                session.removeAttribute("movieName");
                session.removeAttribute("selectedDate");
                session.removeAttribute("selectedTime");
                session.removeAttribute("selectedSeats");
                session.removeAttribute("totalPrice");
                session.removeAttribute("paymentSessionId");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
