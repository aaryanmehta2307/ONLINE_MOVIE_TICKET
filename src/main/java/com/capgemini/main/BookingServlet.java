package com.capgemini.main;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/selectseats")
public class BookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieName = request.getParameter("movieName");
        String showDate = request.getParameter("date");
        String showTime = request.getParameter("time");
        String seats = request.getParameter("seats");
        String totalPrice = request.getParameter("price");

        // Assuming user is logged in and user_id is stored in session
        HttpSession session = request.getSession();
        int userId = (int) session.getAttribute("user_id");

        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/moviedb", "root", "1234");

            String sql = "INSERT INTO bookings (user_id, movie_name, show_date, show_time, seats, total_price) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            stmt.setInt(1, userId);
            stmt.setString(2, movieName);
            stmt.setString(3, showDate);
            stmt.setString(4, showTime);
            stmt.setString(5, seats);
            stmt.setBigDecimal(6, new java.math.BigDecimal(totalPrice));

            int rowsInserted = stmt.executeUpdate();
            if (rowsInserted > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int bookingId = rs.getInt(1);
                    session.setAttribute("bookingId", bookingId);  // Store booking ID for payment reference
                }
            }
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("payment.jsp");
    }
}
