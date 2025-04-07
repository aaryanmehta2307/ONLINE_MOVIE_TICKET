<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if(session.getAttribute("admin") == null){
        response.sendRedirect("admin.jsp");
        return;
    }
    String insertSuccess = request.getParameter("insert_success");
    String deleteSuccess = request.getParameter("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Admin Dashboard</title>
    <style>
        body {
            background: #0f1115;
            color: white;
            font-family: 'Arial', sans-serif;
            padding: 20px;
            text-align: center;
        }
        h1 {
            margin-bottom: 30px;
        }
        .container {
            max-width: 600px;
            margin: auto;
            background: #1c1f2a;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 0px 10px rgba(255, 255, 255, 0.1);
        }
        form {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        input, button {
            padding: 10px;
            border-radius: 5px;
            border: 2px solid black;
            outline: none;
            
        }
        button {
            background: #3742fa;
            color: white;
            cursor: pointer;
            font-weight: bold;
            transition: background 0.3s ease, color 0.3s ease;
        }
        button:hover {
            background: #ddd;
        }

        button.active {
            background: #ff4757 !important;
            color: white !important;
        }

        button.success {
            background: #2ed573 !important;
            color: white !important;
        }

        table {
            margin-top: 30px;
            width: 100%;
            border-collapse: collapse;
            background: #2c2f3b;
        }
        th, td {
            padding: 10px;
            border: 1px solid #444;
        }

        .popup {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 350px;
            background: white;
            color: black;
            padding: 20px;
            text-align: center;
            border-radius: 10px;
            box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.3);
            display: none;
            z-index: 1000;
        }
        .popup button {
            background: #333;
            color: white;
            border: none;
            padding: 10px;
            cursor: pointer;
            margin-top: 10px;
        }

        .logout-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            background: #3742fa;
            padding: 10px 15px;
            border-radius: 8px;
            font-weight: bold;
            color: white;
            text-decoration: none;
        }
        .logout-btn:hover {
            background: #2f35c9;
        }
    </style>
</head>
<body>

<a href="index.jsp" class="logout-btn">Logout</a>

<h1>Welcome Admin &#128104;&#8205;&#127891;</h1> 

<div class="container">
    <h2>Insert Movie</h2>
    <form action="insertMovie.jsp" method="post">
        <input type="text" name="title" placeholder="Movie Title" required>
        <input type="text" name="genre" placeholder="Genre">
        <input type="number" name="duration" min="1" placeholder="Duration (minutes)" required>
        <input type="date" name="release_date" required>
        <button id="insertBtn" type="submit">Insert Movie</button>
    </form>
</div>

<div class="container">
    <h2>Delete Movie</h2>
    <form action="deleteMovie.jsp" method="post">
        <input type="number" name="id" placeholder="Movie ID" required>
        <button id="deleteBtn" type="submit">Delete Movie</button>
    </form>
</div>

<div class="container">
    <h2>Movies Available</h2>
    <form action="showMovies.jsp" method="post">
        <button type="submit" class="nav-btn">Show All Movies</button>
    </form>
</div>

<div class="container">
    <h2>User Bookings</h2>
    <form action="showBookings.jsp" method="post">
        <button type="submit" class="nav-btn">Show All Bookings</button>
    </form>
</div>

<!-- Popup for Insert Success -->
<div id="insertPopup" class="popup">
    <h3>Movie Inserted Successfully!</h3>
    <p>The new movie has been added to the database.</p>
    <button onclick="closePopup('insertPopup')">OK</button>
</div>

<!-- Popup for Delete Success -->
<div id="deletePopup" class="popup">
    <h3>Movie Deleted Successfully!</h3>
    <p>The selected movie has been removed from the database.</p>
    <button onclick="closePopup('deletePopup')">OK</button>
</div>

<script>
    function closePopup(id) {
        document.getElementById(id).style.display = "none";
    }

    window.onload = function () {
        const urlParams = new URLSearchParams(window.location.search);
        
        if (urlParams.get('insert_success') === 'true') {
            document.getElementById("insertPopup").style.display = "block";
            const insertBtn = document.getElementById("insertBtn");
            if (insertBtn) insertBtn.classList.add("success");
        }

        if (urlParams.get('success') === 'true') {
            document.getElementById("deletePopup").style.display = "block";
            const deleteBtn = document.getElementById("deleteBtn");
            if (deleteBtn) deleteBtn.classList.add("success");
        }

        const allButtons = document.querySelectorAll("form button");
        allButtons.forEach(btn => {
            btn.addEventListener("click", function () {
                allButtons.forEach(b => b.classList.remove("active"));
                this.classList.add("active");
            });
        });
    };
</script>

</body>
</html>
