<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login | Movie Ticket Booking</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background: #121212;
        }

        .container {
            background: rgba(0, 0, 0, 0.8);
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(255, 255, 255, 0.3);
            color: white;
            width: 350px;
            text-align: center;
        }

        h2 {
            margin-bottom: 20px;
            font-size: 24px;
        }

        input {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border-radius: 5px;
            border: none;
            outline: none;
            font-size: 16px;
        }

        .btn {
            width: 100%;
            padding: 12px;
            margin-top: 15px;
            background: linear-gradient(135deg, #ff416c, #ff4b2b);
            color: white;
            border: none;
            border-radius: 50px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
        }

        .btn:hover {
            background: linear-gradient(135deg, #ff4b2b, #ff416c);
            box-shadow: 0px 0px 15px rgba(255, 75, 43, 0.7);
        }

        .link-btn {
            background: none;
            border: none;
            color: #ff416c;
            font-weight: bold;
            margin-top: 10px;
            cursor: pointer;
            font-size: 14px;
        }

        .link-btn:hover {
            text-decoration: underline;
        }

        p {
            margin-top: 15px;
        }

        a {
            color: #ff416c;
            text-decoration: none;
            font-weight: bold;
        }

        a:hover {
            text-decoration: underline;
        }

        .popup-card {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #1e1e1e;
            color: white;
            border-left: 5px solid #ff4b2b;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0px 4px 10px rgba(255, 75, 43, 0.3);
            z-index: 1000;
            animation: slideDown 0.3s ease-out;
            min-width: 300px;
            max-width: 90%;
            text-align: left;
        }

        .popup-card .popup-content p {
            margin: 0 0 10px 0;
            font-size: 14px;
        }

        .popup-card .popup-content button {
            background: none;
            border: 1px solid #ff4b2b;
            color: #ff4b2b;
            padding: 5px 10px;
            border-radius: 5px;
            cursor: pointer;
        }

        .popup-card .popup-content button:hover {
            background: #ff4b2b;
            color: white;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>

    <div class="container">
        <h2>Login to Your Account</h2>
        <form action="LoginServlet" method="post">
            <input type="email" name="email" autocomplete="email" placeholder="Email" required>
            <input type="password" name="password" autocomplete="current-password" placeholder="Password" required>
            <button type="submit" class="btn">Login</button>
        </form>
        <p>Don't have an account? <a href="register.jsp">Register</a></p>

        <!-- Admin Login Button -->
        <form action="admin.jsp" method="get">
            <button type="submit" class="link-btn">Admin Login</button>
        </form>
    </div>

    <% if (request.getAttribute("loginFailed") != null) { %>
        <div class="popup-card" id="loginPopup">
            <div class="popup-content">
                <p>Invalid email or password</p>
                <button onclick="document.getElementById('loginPopup').style.display='none'">Close</button>
            </div>
        </div>
        <script>
            setTimeout(() => {
                const popup = document.getElementById("loginPopup");
                if (popup) popup.style.display = "none";
            }, 5000);
        </script>
    <% } %>

</body>
</html>
