<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    if (session == null || session.getAttribute("user_name") == null || session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userName = (String) session.getAttribute("user_name");
    int userId = (session.getAttribute("user_id") instanceof String)
        ? Integer.parseInt((String) session.getAttribute("user_id"))
        : (Integer) session.getAttribute("user_id");

    String dbURL = "jdbc:mysql://localhost:3306/movie_booking";
    String dbUser = "root";
    String dbPass = "1234";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    double walletBalance = 0.0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        String balanceSql = "SELECT balance FROM wallet WHERE user_id = ?";
        stmt = conn.prepareStatement(balanceSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            walletBalance = rs.getDouble("balance");
        }
    } catch (Exception e) {
        out.println("Error fetching balance: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Movie Ticket Booking</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        <%-- External and Internal Styling Combined --%>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap');
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background: #121212; color: white; padding: 20px; }

        .navbar {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            background: #1f1f1f;
            padding: 10px 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }

        .navbar h2 { color: #ff4b2b; }

        .nav-toggle {
            display: none;
            flex-direction: column;
            gap: 5px;
            cursor: pointer;
        }

        .nav-toggle span {
            height: 3px;
            width: 25px;
            background: white;
        }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .wallet-btn {
            padding: 8px 15px;
            background-color: #ff4b2b;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }

        .wallet-dropdown {
            display: none;
            position: absolute;
            right: 20px;
            top: 60px;
            background-color: #1f1f1f;
            border: 1px solid #444;
            padding: 15px;
            border-radius: 10px;
            z-index: 999;
        }

        .logout-btn a {
            padding: 10px 20px;
            background: #ff4b2b;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }

        .logout-btn a:hover { background: darkred; }

        .search-box {
            padding: 8px 10px;
            width: 250px;
            border-radius: 5px;
            border: none;
            font-size: 14px;
        }

        .movies {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
        }

        .card {
            background: #1f1f1f;
            border-radius: 10px;
            overflow: hidden;
            width: 250px;
            transition: transform 0.3s ease;
        }

        .card:hover { transform: scale(1.05); }
        .card img { width: 100%; height: 350px; object-fit: cover; }

        .card-content { padding: 15px; }
        .card-content h3 { margin-bottom: 10px; font-size: 20px; }
        .card-content p { font-size: 14px; color: #b3b3b3; }

        .book-btn {
            margin-top: 10px;
            padding: 10px;
            background: linear-gradient(135deg, #ff416c, #ff4b2b);
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
        }

        .center-text {
            text-align: center;
            margin-bottom: 30px;
        }

        #popupCard {
            position: fixed;
            top: 30px;
            right: 30px;
            background-color: #28a745;
            color: white;
            padding: 15px 25px;
            border-radius: 10px;
            z-index: 999;
            font-weight: bold;
            font-size: 16px;
            animation: fadeInOut 4s ease forwards;
        }

        @keyframes fadeInOut {
            0% { opacity: 0; transform: translateY(-20px); }
            10% { opacity: 1; transform: translateY(0); }
            90% { opacity: 1; transform: translateY(0); }
            100% { opacity: 0; transform: translateY(-20px); }
        }

        @media screen and (max-width: 768px) {
            .nav-right {
                flex-direction: column;
                align-items: flex-start;
                width: 100%;
                display: none;
                gap: 15px;
                margin-top: 10px;
            }

            .nav-right.active {
                display: flex;
            }

            .nav-toggle {
                display: flex;
            }

            .search-box {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<%
    Boolean moneyAdded = (Boolean) session.getAttribute("moneyAdded");
    if (moneyAdded != null && moneyAdded) {
%>
    <div id="popupCard">💰 Money added successfully!</div>
<%
        session.removeAttribute("moneyAdded");
    }
%>

<div class="navbar">
    <h2>🎬 MovieZone</h2>

    <div class="nav-toggle" onclick="toggleNavbar()">
        <span></span><span></span><span></span>
    </div>

    <div class="nav-right" id="navRight">
        <input type="text" id="searchInput" class="search-box" placeholder="Search movies...">
		<button class="wallet-btn" onclick="toggleBookings()">My Bookings</button>
		
        <div style="position: relative;">
            <button class="wallet-btn" onclick="toggleWallet()">Wallet ₹<%= walletBalance %></button>
            <div id="walletDropdown" class="wallet-dropdown">
                <form action="${pageContext.request.contextPath}/AddMoneyServlet" method="post">
                    <input type="number" name="amount" placeholder="Enter amount" required min="1" style="padding: 8px; width: 120px; border-radius: 5px;" />
                    <button type="submit" style="margin-top: 10px; width: 100%; background-color: #28a745; border: none; padding: 8px; color: white; border-radius: 5px;">Add</button>
                </form>
            </div>
        </div>

        <div class="logout-btn">
            <a href="LogoutServlet">Logout</a>
        </div>
    </div>
</div>

<div class="container">
	<div id="bookingsModal" style="display: none; background-color: #1f1f1f; padding: 20px; border-radius: 10px; margin-top: 20px;">
    <h2 style="text-align:center;">📋 Your Bookings</h2>
    <table style="width: 100%; margin-top: 20px; border-collapse: collapse; color: white;">
        <tr style="background-color: #333;">
            <th style="padding: 10px;">Booking ID</th>
            <th>Movie</th>
            <th>Date</th>
            <th>Time</th>
            <th>Seats</th>
            <th>Total</th>
            <th>Status</th>
        </tr>
        <%
            try {
                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                String bookingSql = "SELECT * FROM bookings WHERE user_id = ?";
                stmt = conn.prepareStatement(bookingSql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();

                while (rs.next()) {
        %>
        <tr style="text-align: center; border-bottom: 1px solid #444;">
            <td><%= rs.getInt("booking_id") %></td>
            <td><%= rs.getString("movie_name") %></td>
            <td><%= rs.getDate("show_date") %></td>
            <td><%= rs.getString("show_time") %></td>
            <td><%= rs.getString("seats") %></td>
            <td>₹<%= rs.getDouble("total_price") %></td>
            <td><%= rs.getString("payment_status") %></td>
            <td>
    <form action="DownloadTicketServlet" method="get" target="_blank">
        <input type="hidden" name="bookingId" value="<%= rs.getInt("booking_id") %>" />
        <button type="submit" style="padding: 5px 10px; background-color: #2196f3; color: white; border: none; border-radius: 4px; cursor: pointer;">Download PDF</button>
    </form>
</td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error loading bookings: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            }
        %>
    </table>
</div>
	
    <div class="center-text">
        <h2>Welcome, <%= userName %>! 🎬</h2>
        <p>User ID: <%= userId %></p>
        <p>Select a movie to book your tickets</p>
    </div>

    <div class="movies" id="movieList">
        <%
            try {
                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                String sql = "SELECT id, title, genre, duration, release_date FROM movies";
                stmt = conn.prepareStatement(sql);
                rs = stmt.executeQuery();

                while (rs.next()) {
                    int movieId = rs.getInt("id");
                    String title = rs.getString("title");
                    String genre = rs.getString("genre");
                    int duration = rs.getInt("duration");
                    Date releaseDate = rs.getDate("release_date");
        %>
        <div class="card" data-title="<%= title.toLowerCase() %>">
            <img src="<%= request.getContextPath() %>/images/<%= title.toLowerCase().replace(' ', '-') %>.jpg" alt="<%= title %>">
            <div class="card-content">
                <h3><%= title %></h3>
                <p><%= genre %> | <%= duration %> min | <%= releaseDate %></p>
                <form action="booking.jsp" method="get">
                    <input type="hidden" name="user_id" value="<%= userId %>">
                    <input type="hidden" name="movie_id" value="<%= movieId %>">
                    <input type="hidden" name="movie" value="<%= title %>">
                    <button type="submit" class="book-btn">Book Now</button>
                </form>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error loading movies: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>

<script>
function toggleBookings() {
    const bookingsModal = document.getElementById("bookingsModal");
    bookingsModal.style.display = bookingsModal.style.display === "none" ? "block" : "none";
}

    function toggleWallet() {
        const dropdown = document.getElementById("walletDropdown");
        dropdown.style.display = dropdown.style.display === "block" ? "none" : "block";
    }

    function toggleNavbar() {
        document.getElementById("navRight").classList.toggle("active");
    }

    document.getElementById("searchInput").addEventListener("input", function () {
        const filter = this.value.toLowerCase();
        const cards = document.querySelectorAll(".card");

        cards.forEach(card => {
            const title = card.dataset.title;
            card.style.display = title.includes(filter) ? "block" : "none";
        });
    });
</script>

</body>
</html>
