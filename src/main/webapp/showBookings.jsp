<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Bookings</title>
    <style>
        body { background: #0f1115; color: white; font-family: Arial, sans-serif; padding: 20px; }
        table { width: 100%; border-collapse: collapse; background: #1f1f2e; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #333; text-align: center; }
           .back-button {
    display: inline-block;
    margin-top: 20px;
    padding: 10px 20px;
    background: #3f51b5;
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-weight: bold;
    transition: background 0.3s ease;
    box-shadow: 0 4px 8px rgba(0,0,0,0.3);
}
.back-button:hover {
    background: #303f9f;
}
    </style>
</head>
<body>

<h2>All Bookings</h2>
<table>
    <tr>
        <th>Booking ID</th><th>User ID</th><th>Movie</th><th>Date</th><th>Time</th><th>Seats</th><th>Price</th><th>Status</th>
    </tr>
    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM bookings");

            while(rs.next()) {
    %>
    <tr>
        <td><%= rs.getInt("booking_id") %></td>
        <td><%= rs.getInt("user_id") %></td>
        <td><%= rs.getString("movie_name") %></td>
        <td><%= rs.getDate("show_date") %></td>
        <td><%= rs.getString("show_time") %></td>
        <td><%= rs.getString("seats") %></td>
        <td><%= rs.getDouble("total_price") %></td>
        <td><%= rs.getString("payment_status") %></td>
    </tr>
    <%
            }
            con.close();
        } catch(Exception e) {
            out.println("Error: " + e);
        }
    %>
</table>


<a href="adminDashboard.jsp" class="back-button">&larr; Go Back to Dashboard</a>

</body>
</html>
