package com.capgemini.main;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.sql.*;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

@WebServlet("/DownloadTicketServlet")
public class DownloadTicketServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        String dbURL = "jdbc:mysql://localhost:3306/movie_booking";
        String dbUser = "root";
        String dbPass = "1234";

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=ticket_" + bookingId + ".pdf");

        try {
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            String query = "SELECT * FROM bookings WHERE booking_id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, bookingId);
            ResultSet rs = stmt.executeQuery();

            Document document = new Document(PageSize.A5, 36, 36, 36, 36);
            PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            if (rs.next()) {
                PdfContentByte canvas = writer.getDirectContentUnder();

                // 🎨 Draw background gradient box
                Rectangle rect = new Rectangle(36, 36, PageSize.A5.getWidth() - 36, PageSize.A5.getHeight() - 36);
                rect.setBackgroundColor(new BaseColor(250, 250, 250)); // Light background
                canvas.rectangle(rect);

                // 🖼️ Add logo
                try {
                    String logoPath = getServletContext().getRealPath("/images/home-page.jpg");
                    Image logo = Image.getInstance(logoPath);
                    logo.scaleToFit(80, 80);
                    logo.setAlignment(Image.ALIGN_CENTER);
                    document.add(logo);
                } catch (Exception ex) {
                    System.out.println("Logo not found: " + ex.getMessage());
                }

                // ✨ Title
                Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, BaseColor.DARK_GRAY);
                Paragraph title = new Paragraph("🎟️ Movie Ticket Confirmation", titleFont);
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);
                document.add(Chunk.NEWLINE);

                // Ticket info table
                Font labelFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.GRAY);
                Font valueFont = new Font(Font.FontFamily.HELVETICA, 12, Font.NORMAL, BaseColor.BLACK);

                PdfPTable ticketTable = new PdfPTable(2);
                ticketTable.setWidthPercentage(100);
                ticketTable.setWidths(new float[]{3f, 5f});

                addRow(ticketTable, "📅 Booking ID", String.valueOf(bookingId), labelFont, valueFont);
                addRow(ticketTable, "🎥 Movie Name", rs.getString("movie_name"), labelFont, valueFont);
                addRow(ticketTable, "🗓️ Show Date", rs.getDate("show_date").toString(), labelFont, valueFont);
                addRow(ticketTable, "🕒 Show Time", rs.getString("show_time"), labelFont, valueFont);
                addRow(ticketTable, "💺 Seats", rs.getString("seats"), labelFont, valueFont);
                addRow(ticketTable, "💵 Total Price", "₹" + rs.getDouble("total_price"), labelFont, valueFont);
                addRow(ticketTable, "💳 Payment Status", rs.getString("payment_status"), labelFont, valueFont);

                PdfPCell ticketWrapper = new PdfPCell(ticketTable);
                ticketWrapper.setBorderColor(BaseColor.LIGHT_GRAY);
                ticketWrapper.setPadding(10f);
                ticketWrapper.setBorderWidth(1f);
                ticketWrapper.setBackgroundColor(new BaseColor(255, 255, 255));

                PdfPTable wrapperTable = new PdfPTable(1);
                wrapperTable.setWidthPercentage(100);
                wrapperTable.addCell(ticketWrapper);
                document.add(wrapperTable);

                document.add(Chunk.NEWLINE);

                // 📱 QR Code for Booking ID
                BarcodeQRCode qrCode = new BarcodeQRCode("BookingID:" + bookingId, 100, 100, null);
                Image qrImage = qrCode.getImage();
                qrImage.scaleAbsolute(80, 80);
                qrImage.setAlignment(Image.ALIGN_CENTER);
                document.add(qrImage);

                document.add(Chunk.NEWLINE);

                // 👋 Thank you note
                Font footerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC, BaseColor.GRAY);
                Paragraph thanks = new Paragraph("✅ Thank you for booking with MovieZone!\nEnjoy your movie experience!", footerFont);
                thanks.setAlignment(Element.ALIGN_CENTER);
                document.add(thanks);
            }

            document.close();
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label + ":", labelFont));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPadding(6f);

        PdfPCell valueCell = new PdfPCell(new Phrase(value, valueFont));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setPadding(6f);

        table.addCell(labelCell);
        table.addCell(valueCell);
    }
}
