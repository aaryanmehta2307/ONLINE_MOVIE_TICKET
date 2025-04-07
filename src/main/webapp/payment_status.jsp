<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String status = request.getParameter("status");
    String message = "❌ Payment Failed! Insufficient Balance.";
    String alertClass = "alert-danger";

    if ("success".equals(status)) {
        message = "✅ Payment Successful!";
        alertClass = "alert-success";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Status</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .container { max-width: 400px; text-align: center; background: white; padding: 30px; border-radius: 10px; box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1); }
        .dashboard-btn { display: block; margin-top: 20px; padding: 10px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
    </style>
</head>
<body>

    <div class="container">
        <div class="alert <%= alertClass %>">
            <%= message %>
        </div>
        <a href="dashboard.jsp" class="dashboard-btn">Return to Dashboard</a>
    </div>

</body>
</html>
