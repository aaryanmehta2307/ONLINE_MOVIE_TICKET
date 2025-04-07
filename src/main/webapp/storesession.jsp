<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    HttpSession sess = request.getSession();

    // Retrieve and trim request parameters
    String userId = request.getParameter("user_id");
    String movieId = request.getParameter("movie_id");
    String movieName = request.getParameter("movieName");
    String selectedDate = request.getParameter("selectedDate");
    String selectedTime = request.getParameter("selectedTime");

    // Basic null and empty checks
    boolean isInvalid = userId == null || movieId == null || movieName == null ||
                        selectedDate == null || selectedTime == null ||
                        userId.trim().isEmpty() || movieId.trim().isEmpty() ||
                        movieName.trim().isEmpty() || selectedDate.trim().isEmpty() || selectedTime.trim().isEmpty();

    if (isInvalid) {
        response.sendRedirect("booking.jsp");
        return;
    }

    // Store in session
    sess.setAttribute("user_id", userId);
    sess.setAttribute("movie_id", movieId);
    sess.setAttribute("movieName", movieName);
    sess.setAttribute("selectedDate", selectedDate);
    sess.setAttribute("selectedTime", selectedTime);

    // Encode values for URL safety
    String encodedMovieName = java.net.URLEncoder.encode(movieName, "UTF-8");
    String encodedDate = java.net.URLEncoder.encode(selectedDate, "UTF-8");
    String encodedTime = java.net.URLEncoder.encode(selectedTime, "UTF-8");

    // Redirect to seat selection page
    response.sendRedirect("selectseats.jsp?user_id=" + userId + "&movie_id=" + movieId +
                          "&movieName=" + encodedMovieName + "&selectedDate=" + encodedDate +
                          "&selectedTime=" + encodedTime);
%>
