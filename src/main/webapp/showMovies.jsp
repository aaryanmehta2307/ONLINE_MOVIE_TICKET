<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Movies</title>
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

<h2>All Movies</h2>
<table>
    <tr>
        <th>Movie ID</th><th>Title</th><th>Genre</th><th>Duration</th><th>Release Date</th>
    </tr>
    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM movies");

            while(rs.next()) {
    %>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("title") %></td>
        <td><%= rs.getString("genre") %></td>
        <td><%= rs.getInt("duration") %> min</td>
        <td><%= rs.getDate("release_date") %></td>
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
