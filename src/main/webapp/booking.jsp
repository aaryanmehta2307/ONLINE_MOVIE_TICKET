<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    HttpSession sess = request.getSession();

    String userId = request.getParameter("user_id");
    String movieId = request.getParameter("movie_id");
    String movieName = request.getParameter("movie");

    if (userId == null || movieId == null || movieName == null || movieName.isEmpty()) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    sess.setAttribute("user_id", userId);
    sess.setAttribute("movie_id", movieId);
    sess.setAttribute("movieName", movieName);

    String[] showTimes = {"10:00 AM", "1:00 PM", "4:00 PM", "7:00 PM", "10:00 PM"};
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="theme-color" content="#121212">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Ticket | <%= movieName %></title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #121212;
            color: white;
            text-align: center;
            padding: 20px;
        }

        .container {
            max-width: 600px;
            margin: auto;
            padding: 20px;
        }

        .info {
            background: #1f1f1f;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .date-picker input {
            padding: 10px;
            font-size: 16px;
            border-radius: 8px;
            border: 1px solid #ff4b2b;
            background: #1f1f1f;
            color: white;
            cursor: pointer;
        }

        .showtimes {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }

        .showtime-btn {
            background: #1f1f1f;
            border: 1px solid #ff4b2b;
            color: #ff4b2b;
            padding: 10px 15px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: 0.3s;
        }

        .showtime-btn:hover {
            background: #ff4b2b;
            color: white;
        }

        .disabled {
            opacity: 0.5;
            pointer-events: none;
        }

        .next-btn {
            margin-top: 30px;
            padding: 12px 20px;
            background: #ff4b2b;
            color: white;
            font-size: 18px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            display: none;
        }

        #summary {
            margin-top: 20px;
            font-size: 16px;
            color: #ccc;
        }
    </style>

    <script>
        let selectedDate = "";
        let selectedTime = "";

        function setMinDate() {
            let today = new Date();
            let minDate = today.toISOString().split('T')[0];

            let dateInput = document.getElementById("date-picker");
            dateInput.setAttribute("min", minDate);
            dateInput.value = minDate;
            selectedDate = minDate;
            filterShowtimes();
        }

        function selectDate() {
            selectedDate = document.getElementById("date-picker").value;
            filterShowtimes();
            updateSummary();
        }

        function filterShowtimes() {
            let now = new Date();
            let selectedDateObj = new Date(selectedDate);
            let currentTime = now.getHours() * 60 + now.getMinutes();

            document.querySelectorAll('.showtime-btn').forEach(btn => {
                let timeText = btn.innerText;
                let [time, period] = timeText.split(' ');
                let [hours, minutes] = time.split(':').map(Number);

                if (period === "PM" && hours !== 12) hours += 12;
                if (period === "AM" && hours === 12) hours = 0;

                let showTimeMinutes = hours * 60 + minutes;

                if (selectedDateObj.toDateString() === now.toDateString() && showTimeMinutes < currentTime) {
                    btn.classList.add("disabled");
                    btn.title = "This showtime has passed.";
                } else {
                    btn.classList.remove("disabled");
                    btn.removeAttribute("title");
                }
            });
        }

        function selectTime(time, event) {
            if (selectedDate === "") {
                alert("Please select a date first!");
                return;
            }
            selectedTime = time;
            document.querySelectorAll('.showtime-btn').forEach(btn => btn.style.opacity = "0.5");
            event.target.style.opacity = "1";
            document.getElementById('next-btn').style.display = "inline-block";
            updateSummary();
        }

        function updateSummary() {
            let summary = document.getElementById('summary');
            if (selectedDate && selectedTime) {
                summary.innerText = `Selected: ${selectedDate} at ${selectedTime}`;
            } else if (selectedDate) {
                summary.innerText = `Selected Date: ${selectedDate}`;
            } else {
                summary.innerText = "";
            }
        }

        function goToSeatSelection() {
            if (selectedDate === "" || selectedTime === "") {
                alert("Please select both a date and time before proceeding!");
                return;
            }

            document.getElementById("selectedDate").value = selectedDate;
            document.getElementById("selectedTime").value = selectedTime;
            document.getElementById("sessionForm").submit();
        }

        window.onload = setMinDate;
    </script>
</head>
<body>

<div class="container">
    <div class="info">
        <h3>User ID: <%= userId %></h3>
        <h3>Movie ID: <%= movieId %></h3>
    </div>

    <h2>Book Tickets for <%= movieName %> 🎟</h2>

    <h3>Select a Date</h3>
    <div class="date-picker">
        <input type="date" id="date-picker" onchange="selectDate()">
    </div>

    <h3>Select a Showtime</h3>
    <div class="showtimes">
        <% for (String time : showTimes) { %>
            <button class="showtime-btn" onclick="selectTime('<%= time %>', event)"><%= time %></button>
        <% } %>
    </div>

    <div id="summary"></div>

    <form id="sessionForm" method="POST" action="storesession.jsp">
        <input type="hidden" name="user_id" value="<%= userId %>">
        <input type="hidden" name="movie_id" value="<%= movieId %>">
        <input type="hidden" name="movieName" value="<%= movieName %>">
        <input type="hidden" name="selectedDate" id="selectedDate">
        <input type="hidden" name="selectedTime" id="selectedTime">
    </form>

    <button id="next-btn" class="next-btn" onclick="goToSeatSelection()">Next</button>
</div>

</body>
</html>
