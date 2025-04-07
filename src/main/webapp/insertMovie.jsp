<%@ page import="java.sql.*" %>
<%
    String title = request.getParameter("title");
    String genre = request.getParameter("genre");
    String durationParam = request.getParameter("duration");
    int duration = 0;
    if (durationParam != null && !durationParam.trim().isEmpty()) {
        duration = Integer.parseInt(durationParam);
    } else {
        response.sendRedirect("adminDashboard.jsp?insert_success=false&error=missing_duration");
        return;
    }

    String release = request.getParameter("release_date");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");

        // Fetch the next available ID
        PreparedStatement ps1 = con.prepareStatement(
            "SELECT MIN(id + 1) AS next_id FROM movies WHERE (id + 1) NOT IN (SELECT id FROM movies)"
        );
        ResultSet rs = ps1.executeQuery();
        int nextId = 1; // Default to 1 if table is empty

        if (rs.next() && rs.getInt("next_id") != 0) {
            nextId = rs.getInt("next_id");
        } else {
            // If no missing ID, use the next available auto-increment ID
            PreparedStatement ps2 = con.prepareStatement("SELECT MAX(id) + 1 FROM movies");
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) {
                nextId = rs2.getInt(1);
            }
        }

        // Insert with manually assigned ID
        PreparedStatement ps3 = con.prepareStatement("INSERT INTO movies(id, title, genre, duration, release_date) VALUES (?, ?, ?, ?, ?)");
        ps3.setInt(1, nextId);
        ps3.setString(2, title);
        ps3.setString(3, genre);
        ps3.setInt(4, duration);
        ps3.setDate(5, Date.valueOf(release));

        ps3.executeUpdate();
        con.close();

        response.sendRedirect("adminDashboard.jsp?insert_success=true");
    } catch(Exception e) {
        response.sendRedirect("adminDashboard.jsp?insert_success=false");
    }
%>
