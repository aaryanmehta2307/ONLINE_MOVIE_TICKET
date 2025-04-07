<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
<%
    HttpSession sess = request.getSession();

    // Redirect to login if user is not logged in
    if (sess.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Session timeout logic (70 seconds)
    Long currentTime = System.currentTimeMillis();
    Long paymentStartTime = (Long) sess.getAttribute("paymentSessionId");
    if (paymentStartTime == null || currentTime - paymentStartTime > 70000) {
        sess.setAttribute("paymentSessionId", currentTime);
        sess.removeAttribute("paymentStatus");
        sess.removeAttribute("bookingInserted");
        sess.removeAttribute("bookingId");
    }

    int userId = Integer.parseInt((String) sess.getAttribute("user_id"));
    String movieId = (String) sess.getAttribute("movie_id");
    String movieName = (String) sess.getAttribute("movieName");
    String selectedDate = (String) sess.getAttribute("selectedDate");
    String selectedTime = (String) sess.getAttribute("selectedTime");
    String selectedSeats = (String) sess.getAttribute("selectedSeats");
    String totalPriceStr = (String) sess.getAttribute("totalPrice");
    double totalPrice = 0.0;

    if (totalPriceStr != null && !totalPriceStr.trim().isEmpty()) {
        totalPrice = Double.parseDouble(totalPriceStr);
    }

    String dbURL = "jdbc:mysql://localhost:3306/movie_booking";
    String dbUser = "root";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    double walletBalance = 0.0;
    int bookingId = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        if (sess.getAttribute("bookingInserted") == null) {
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            String insertSql = "INSERT INTO bookings (user_id, movie_id, movie_name, show_date, show_time, seats, total_price, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending')";
            stmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, userId);
            stmt.setString(2, movieId);
            stmt.setString(3, movieName);
            stmt.setString(4, selectedDate);
            stmt.setString(5, selectedTime);
            stmt.setString(6, selectedSeats);
            stmt.setDouble(7, totalPrice);
            stmt.executeUpdate();

            rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                bookingId = rs.getInt(1);
                sess.setAttribute("bookingId", bookingId);
            }

            sess.setAttribute("bookingInserted", true);
        } else {
            bookingId = (int) sess.getAttribute("bookingId");
        }

        if (conn == null || conn.isClosed()) conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        stmt = conn.prepareStatement("SELECT balance FROM wallet WHERE user_id = ?");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) walletBalance = rs.getDouble("balance");

    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; font-family: 'Poppins', sans-serif; padding: 20px; }
        .container { max-width: 500px; background: white; padding: 20px; border-radius: 10px; box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1); }
        .payment-option { display: flex; align-items: center; margin-bottom: 15px; padding: 12px; border: 2px solid #ddd; border-radius: 8px; cursor: pointer; background: #fff; }
        .payment-option input { margin-right: 15px; }
        .payment-option img { width: 40px; height: 40px; margin-left: 10px; }
        .pay-now-btn { width: 100%; padding: 12px; font-size: 18px; font-weight: bold; border-radius: 8px; cursor: pointer; background: #28a745; color: white; border: none; }
        .pay-now-btn:hover { background: #218838; }
        .coming-soon { color: gray; font-size: 14px; margin-left: auto; }
        .dashboard-btn {
            display: block;
            text-align: center;
            margin-top: 20px;
            padding: 12px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            transition: background 0.3s ease;
        }
        .dashboard-btn:hover { background: #0056b3; }
        .alert { font-size: 18px; padding: 15px; text-align: center; border-radius: 8px; }
        .timer {
    font-size: 20px;
    text-align: center;
    margin-bottom: 15px;
    font-weight: bold;
    color: #dc3545;
    background: #fff3cd;
    padding: 10px;
    border-radius: 8px;
    border: 1px solid #ffeeba;
}

        #timeoutModal {
            display: none;
            position: fixed;
            z-index: 999;
            left: 0; top: 0; width: 100%; height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
        }

        #timeoutModal .modal-content {
            background: white;
            margin: 15% auto;
            padding: 30px;
            border-radius: 12px;
            max-width: 400px;
            text-align: center;
            box-shadow: 0px 8px 20px rgba(0,0,0,0.2);
        }
		
        #timeoutModal h5 {
            font-size: 20px;
            margin-bottom: 20px;
        }

        #timeoutModal .dashboard-btn {
            margin: 0 auto;
        }
    </style>
</head>
<body>

    
<div class="container">
<div id="timer" class="timer" data-seats="<%= selectedSeats %>">⏳ Payment timeout in: 60s</div>

    <h2 class="text-center mb-4">Choose Payment Method</h2>

    <% if (totalPriceStr == null || totalPriceStr.trim().isEmpty()) { %>
        <!-- Total price is not set -->
    <% } else { %>
        <p class="alert alert-info">Total Price: ₹<%= totalPrice %></p>
    <% } %>

    <% if ("success".equals(sess.getAttribute("paymentStatus"))) { %>
        <div class="alert alert-success">✅ Payment Successful!</div>
        <a href="dashboard.jsp" class="dashboard-btn">Return to Dashboard</a>
    <% } else if ("failed".equals(sess.getAttribute("paymentStatus"))) { %>
        <div class="alert alert-danger">❌ Payment Failed! Insufficient Balance or Timeout.</div>
        <a href="dashboard.jsp" class="dashboard-btn">Return to Dashboard</a>
    <% } else { %>

    <form method="post" action="PaymentServlet">
        <label class="payment-option">
            <input type="radio" name="paymentMethod" value="wallet" required>
            Wallet (Balance: ₹<%= walletBalance %>)
        </label>

        <label class="payment-option">
            <input type="radio" name="paymentMethod" value="debit" disabled>
            Debit Card <span class="coming-soon">Coming Soon</span>
        </label>

        <label class="payment-option">
            <input type="radio" name="paymentMethod" value="credit" disabled>
            Credit Card <span class="coming-soon">Coming Soon</span>
        </label>

        <label class="payment-option">
            <input type="radio" name="paymentMethod" value="upi" disabled>
            UPI <span class="coming-soon">Coming Soon</span>
            <img src="<%= request.getContextPath() %>/images/google-pay.png" alt="Google Pay">
            <img src="<%= request.getContextPath() %>/images/phone-pe.png" alt="PhonePe">
            <img src="<%= request.getContextPath() %>/images/paytm.png" alt="Paytm">
        </label>

        <button type="submit" class="pay-now-btn">Pay Now</button>
    </form>
    <% } %>

    <% 
        if ("success".equals(sess.getAttribute("paymentStatus")) || "failed".equals(sess.getAttribute("paymentStatus"))) {
            sess.removeAttribute("paymentStatus");
        }
    %>
</div>

<!-- Modal for Timeout -->
<div id="timeoutModal">
    <div class="modal-content">
        <h5>⏳ Payment Timed Out!</h5>
        <p>Your session expired due to inactivity. No charges were applied.</p>
        <a href="dashboard.jsp" class="dashboard-btn">Return to Dashboard</a>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        let timeLeft = 60;
        const timerEl = document.getElementById("timer");

        const selectedSeats = timerEl.dataset.seats;

        const countdown = () => {
            if (timeLeft > 0) {
                timerEl.innerText = "⏳ Payment timeout in: " + timeLeft + "s";
                timeLeft--;
                setTimeout(countdown, 1000);
            }
        };
        countdown();

        setTimeout(() => {
            fetch("CancelPaymentServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "selectedSeats=" + encodeURIComponent(selectedSeats)
            }).then(() => {
                document.getElementById("timeoutModal").style.display = "block";
                document.querySelector(".container").style.display = "none";
            });
        }, 60000);

        window.onbeforeunload = function () {
            navigator.sendBeacon("CancelPaymentServlet", new URLSearchParams({
                selectedSeats: selectedSeats
            }));
        };
    });
</script>



</body>
</html>
