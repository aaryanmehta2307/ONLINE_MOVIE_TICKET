<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Online Movie Ticket Booking</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background: url('<%= request.getContextPath() %>/images/home-page.jpg') no-repeat center center/cover;
}


        .container {
            background: rgba(0, 0, 0, 0.75); /* Dark overlay effect */
            padding: 50px 40px;
            border-radius: 12px;
            box-shadow: 0px 6px 15px rgba(255, 255, 255, 0.2);
            max-width: 550px;
            text-align: center;
        }

        h1 {
            font-size: 30px;
            font-weight: 600;
            margin-bottom: 20px;
            color: white;
        }

        p {
            font-size: 17px;
            margin-bottom: 25px;
            opacity: 0.85;
            color: white;
        }

        .btn {
            display: inline-block;
            background: linear-gradient(135deg, #ff416c, #ff4b2b);
            color: white;
            padding: 12px 24px;
            border-radius: 30px;
            font-size: 15px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            text-decoration: none;
            margin: 10px 8px;
            transition: 0.3s ease-in-out;
        }

        .btn:hover {
            background: linear-gradient(135deg, #ff4b2b, #ff416c);
            box-shadow: 0px 0px 15px rgba(255, 75, 43, 0.8);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

    <div class="container">
        <h1>🎬 Welcome to Movie Ticket Booking</h1>
        <p>Book your favorite movie tickets easily and enjoy the show with us!</p>
        <div class="btn-container">
            <a href="login.jsp" class="btn">Login</a>
            <a href="register.jsp" class="btn">Register</a>
            <a href="admin.jsp" class="btn">Admin Login</a>
        </div>
    </div>

</body>
</html>
