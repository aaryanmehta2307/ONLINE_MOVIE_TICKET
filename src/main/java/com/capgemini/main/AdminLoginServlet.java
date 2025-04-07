package com.capgemini.main;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.sql.*;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");
            PreparedStatement pst = con.prepareStatement("SELECT * FROM admin WHERE username=? AND password=?");
            pst.setString(1, uname);
            pst.setString(2, pass);

            ResultSet rs = pst.executeQuery();

            if(rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("admin", uname);
                response.sendRedirect("adminDashboard.jsp");
            } else {
                response.getWriter().println("<script>alert('Invalid Credentials!');window.location='admin.jsp';</script>");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
