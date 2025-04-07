<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    // Get session
    HttpSession sess = request.getSession();

    // Retrieve values from session or request
    String userId = (String) sess.getAttribute("user_id");
    String movieId = (String) sess.getAttribute("movie_id");
    String movieName = (String) sess.getAttribute("movieName");
    String selectedDate = (String) sess.getAttribute("selectedDate");
    String selectedTime = (String) sess.getAttribute("selectedTime");

    if (userId == null) userId = request.getParameter("user_id");
    if (movieId == null) movieId = request.getParameter("movie_id");
    if (movieName == null) movieName = request.getParameter("movieName");
    if (selectedDate == null) selectedDate = request.getParameter("selectedDate");
    if (selectedTime == null) selectedTime = request.getParameter("selectedTime");

    String selectedSeats = request.getParameter("selectedSeats");
    String totalPrice = request.getParameter("totalPrice");

    // Validate all required inputs
    if (userId == null || movieId == null || movieName == null || selectedDate == null ||
        selectedTime == null || selectedSeats == null || totalPrice == null) {
        out.println("<p style='color:red; text-align:center;'><b>⚠️ Missing booking details. Please try again.</b></p>");
        return;
    }

    // Store booking data in session for payment.jsp
    sess.setAttribute("user_id", userId);
    sess.setAttribute("movie_id", movieId);
    sess.setAttribute("movieName", movieName);
    sess.setAttribute("selectedDate", selectedDate);
    sess.setAttribute("selectedTime", selectedTime);
    sess.setAttribute("selectedSeats", selectedSeats);
    sess.setAttribute("totalPrice", totalPrice);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Booking Confirmation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 40px 20px;
        }
        .container {
            max-width: 500px;
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            margin: auto;
        }
        .btn-primary {
            background-color: #007bff;
            border: none;
            padding: 12px;
            width: 100%;
            font-size: 16px;
            border-radius: 8px;
        }
        .btn-primary:hover {
            background-color: #0056b3;
        }
        .list-group-item {
            font-size: 16px;
        }
    </style>
</head>
<body>

<div class="container">
    <h3 class="text-center text-success mb-4">Almost There! 🎉</h3>
    <h5 class="text-center mb-3">🎬 <%= movieName %></h5>
    <ul class="list-group mb-4">
        <li class="list-group-item"><strong>📅 Date:</strong> <%= selectedDate %></li>
        <li class="list-group-item"><strong>⏰ Time:</strong> <%= selectedTime %></li>
        <li class="list-group-item"><strong>💺 Seats:</strong> <%= selectedSeats %></li>
        <li class="list-group-item"><strong>💰 Total Price:</strong> ₹<%= totalPrice %></li>
    </ul>
    <a href="payment.jsp" class="btn btn-primary">Proceed to Payment</a>
</div>

</body>
</html>
