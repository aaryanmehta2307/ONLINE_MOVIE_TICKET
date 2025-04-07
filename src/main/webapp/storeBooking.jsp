<%@ page import="java.sql.*" %>
<%
    String userId = (String) session.getAttribute("user_id");  // Ensure user is logged in
    String movieId = request.getParameter("movieId");
    String date = request.getParameter("date");
    String time = request.getParameter("time");
    String seats = request.getParameter("seats");
    String price = request.getParameter("price");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");

        String sql = "INSERT INTO bookings (user_id, movie_id, show_date, show_time, seats, total_price, payment_status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')";
        ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        ps.setInt(1, Integer.parseInt(userId));
        ps.setInt(2, Integer.parseInt(movieId));
        ps.setString(3, date);
        ps.setString(4, time);
        ps.setString(5, seats);
        ps.setDouble(6, Double.parseDouble(price));

        int rowsAffected = ps.executeUpdate();

        if (rowsAffected > 0) {
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int bookingId = rs.getInt(1);
                out.print(bookingId);
            }
        } else {
            out.print("error");
        }
    } catch (Exception e) {
        out.print("error");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
