<%@ page import="java.sql.*, javax.servlet.*, javax.servlet.http.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login - ScreenTimeNow</title>
    <style>
        body {
            background-color: #0f1115;
            color: white;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .login-box {
            background: #1e1e2f;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0px 0px 12px rgba(255, 255, 255, 0.2);
            text-align: center;
        }
        input[type="text"], input[type="password"] {
            padding: 10px;
            margin: 10px;
            width: 80%;
            border-radius: 5px;
            border: none;
        }
        input[type="submit"] {
            padding: 10px 20px;
            background: #ff416c;
            border: none;
            color: white;
            border-radius: 5px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background: #ff4b2b;
        }
        .link-btn {
            background: none;
            border: none;
            color: #ff416c;
            font-weight: bold;
            margin-top: 15px;
            font-size: 14px;
            cursor: pointer;
        }
        .link-btn:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="login-box">
    <h2>Admin Login</h2>
    <form action="AdminLoginServlet" method="post">
        <input type="text" name="username" placeholder="Admin Username" required><br>
        <input type="password" name="password" placeholder="Password" required><br>
        <input type="submit" value="Login">
    </form>

    <!-- Additional navigation buttons -->
    <form action="login.jsp" method="get">
        <button type="submit" class="link-btn">User Login</button>
    </form>
    <form action="register.jsp" method="get">
        <button type="submit" class="link-btn">Register</button>
    </form>
</div>

</body>
</html>
