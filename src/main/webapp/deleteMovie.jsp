<%@ page import="java.sql.*" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");
        PreparedStatement ps = con.prepareStatement("DELETE FROM movies WHERE id=?");
        ps.setInt(1, id);
        int rowsAffected = ps.executeUpdate();
        con.close();
        
        if(rowsAffected > 0) {
            response.sendRedirect("adminDashboard.jsp?success=true");
        } else {
            response.sendRedirect("adminDashboard.jsp?success=false");
        }
    } catch(Exception e) {
        response.sendRedirect("adminDashboard.jsp?success=false");
    }
%>
