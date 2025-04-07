<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user_id") == null || sess.getAttribute("movie_id") == null) {
        response.sendRedirect("booking.jsp?error=sessionExpired");
        return;
    }

    String userId = (String) sess.getAttribute("user_id");
    String movieId = (String) sess.getAttribute("movie_id");
    String movieName = (String) sess.getAttribute("movieName");
    String selectedDate = (String) sess.getAttribute("selectedDate");
    String selectedTime = (String) sess.getAttribute("selectedTime");

    String[] sections = {"Diamond", "Gold", "Silver"};
    int[] prices = {700, 400, 200};
    char[] startRows = {'A', 'C', 'K'};
    char[] endRows = {'B', 'J', 'N'};

    Map<String, String> seatStatus = new HashMap<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/movie_booking", "root", "1234");

        PreparedStatement ps = con.prepareStatement(
            "SELECT seats, payment_status FROM bookings WHERE movie_id = ? AND show_date = ? AND show_time = ?"
        );
        ps.setString(1, movieId);
        ps.setString(2, selectedDate);
        ps.setString(3, selectedTime);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            String[] seats = rs.getString("seats").split(",");
            String status = rs.getString("payment_status").toLowerCase();
            if (!status.equals("failed")) {
                for (String seat : seats) {
                    seatStatus.put(seat.trim(), status);
                }
            }
        }

        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        out.println("<script>alert('Database Error! Try again later.'); window.location='booking.jsp';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Select Seats | <%= movieName %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            background: #121212;
            color: white;
        }
        .info {
            background: #1f1f1f;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .section {
            margin: 20px auto;
        }
        .seat-container {
            display: grid;
            grid-template-columns: repeat(22, 40px);
            gap: 5px;
            justify-content: center;
        }
        .seat {
            width: 40px;
            height: 40px;
            background-color: lightblue;
            border: 1px solid #000;
            text-align: center;
            line-height: 40px;
            cursor: pointer;
        }
        .gap {
            width: 120px;
        }
        .selected {
            background-color: green;
            color: white;
        }
        .blocked {
            background-color: gray !important;
            pointer-events: none;
        }
        .pending {
            background-color: orange !important;
            pointer-events: none;
        }
        .book-button {
            display: none;
            margin-top: 15px;
            padding: 12px 20px;
            background: linear-gradient(135deg, #ff416c, #ff4b2b);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
        }
        .book-button:hover {
            box-shadow: 0 0 10px rgba(255, 75, 43, 0.7);
        }
        .price-info {
            margin-top: 10px;
            font-size: 18px;
            font-weight: bold;
        }
        .screen-container {
            margin-top: 30px;
            display: flex;
            justify-content: center;
        }
        .legend {
            display: flex;
            justify-content: center;
            margin-top: 20px;
            gap: 15px;
        }
        .legend div {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .legend-box {
            width: 20px;
            height: 20px;
            border: 1px solid #fff;
        }
        .available { background: lightblue; }
        .selected-box { background: green; }
        .blocked-box { background: gray; }
        .pending-box { background: orange; }
    </style>
</head>
<body>

    <% if ("sessionExpired".equals(request.getParameter("error"))) { %>
        <script>alert("Session expired. Please book again.");</script>
    <% } %>

    <div class="info">
        <h3>User: <%= userId %></h3>
        <h3>Movie: <%= movieName %> (ID: <%= movieId %>)</h3>
        <h4>Date: <%= selectedDate %> | Time: <%= selectedTime %></h4>
    </div>

    <h2>Select Your Seats</h2>

    <% for (int i = 0; i < sections.length; i++) { %>
        <div class="section">
            <h3><%= sections[i] %> Section - ₹<%= prices[i] %>/seat</h3>
            <div class="seat-container">
                <% for (char row = startRows[i]; row <= endRows[i]; row++) {
                    for (int seat = 1; seat <= 22; seat++) {
                        String seatCode = row + String.valueOf(seat);
                        String status = seatStatus.get(seatCode);
                %>
                    <% if (seat == 6 || seat == 18) { %>
                        <div class="gap"></div>
                    <% } else if ("completed".equals(status)) { %>
                        <div class="seat blocked" title="Booked" aria-label="Seat <%= seatCode %> (Booked)"><%= seatCode %></div>
                    <% } else if ("pending".equals(status)) { %>
                        <div class="seat pending" title="Pending Payment" aria-label="Seat <%= seatCode %> (Pending)"><%= seatCode %></div>
                    <% } else { %>
                        <div class="seat" role="checkbox" aria-checked="false" data-price="<%= prices[i] %>" onclick="selectSeat(this)" aria-label="Seat <%= seatCode %>"><%= seatCode %></div>
                    <% } %>
                <% } } %>
            </div>
        </div>
    <% } %>

    <div class="price-info" id="totalPrice">Total Price: ₹0</div>

    <form id="bookingForm" method="POST" action="bookTicket.jsp">
        <input type="hidden" name="user_id" value="<%= userId %>">
        <input type="hidden" name="movie_id" value="<%= movieId %>">
        <input type="hidden" name="movieName" value="<%= movieName %>">
        <input type="hidden" name="selectedDate" value="<%= selectedDate %>">
        <input type="hidden" name="selectedTime" value="<%= selectedTime %>">
        <input type="hidden" name="selectedSeats" id="selectedSeats">
        <input type="hidden" name="totalPrice" id="totalPriceValue">
        <button type="submit" class="book-button" id="bookButton">Book Ticket</button>
    </form>

    <div class="legend">
        <div><div class="legend-box available"></div>Available</div>
        <div><div class="legend-box selected-box"></div>Selected</div>
        <div><div class="legend-box blocked-box"></div>Booked</div>
        <div><div class="legend-box pending-box"></div>Pending</div>
    </div>

    <div class="screen-container">
        <img src="<%= request.getContextPath() %>/images/screen-this-way.svg" alt="Screen this way">
    </div>

    <script>
        let selectedSeats = [];
        let totalPrice = 0;

        function selectSeat(seat) {
            let seatPrice = parseInt(seat.getAttribute("data-price"));
            let isSelected = seat.classList.contains("selected");

            if (isSelected) {
                seat.classList.remove("selected");
                seat.setAttribute("aria-checked", "false");
                selectedSeats = selectedSeats.filter(s => s !== seat.textContent);
                totalPrice -= seatPrice;
            } else {
                seat.classList.add("selected");
                seat.setAttribute("aria-checked", "true");
                selectedSeats.push(seat.textContent);
                totalPrice += seatPrice;
            }

            document.getElementById("totalPrice").textContent = "Total Price: ₹" + totalPrice;
            document.getElementById("selectedSeats").value = selectedSeats.join(",");
            document.getElementById("totalPriceValue").value = totalPrice;
            document.getElementById("bookButton").style.display = selectedSeats.length > 0 ? "block" : "none";
        }

        // Prevent resubmission on refresh
        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }

        // Client-side form validation
        document.getElementById("bookingForm").addEventListener("submit", function(e) {
            if (selectedSeats.length === 0) {
                e.preventDefault();
                alert("Please select at least one seat.");
            }
        });
    </script>

</body>
</html>
