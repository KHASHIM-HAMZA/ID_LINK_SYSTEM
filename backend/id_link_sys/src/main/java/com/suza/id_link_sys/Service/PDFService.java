package com.suza.id_link_sys.Service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.qrcode.QRCodeWriter;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.HorizontalAlignment;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.OutputStream;
import java.nio.file.FileSystems;
import java.nio.file.Path;

@Service
public class PDFService {

    @Autowired
    StudentIDRequestRepository studentIDRequestRepository;

    static String UNIVERSITY_LOGO_PATH = "/home/gokyumi/work/idl_system/uploads/Pasted image.png";

    /**
     * Generates and saves a student's ID card as a PDF file on disk.
     */

    public static String generateStudentIDCard(StudentIDRequest student) throws Exception {
        String fileName = student.getRegNumber().replace("/", "_");
        String pdfPath = "/home/gokyumi/work/idl_system/uploads/idcards/" + fileName + "_idcard.pdf";
        String pngPath = "/home/gokyumi/work/idl_system/uploads/idcards/" + fileName + "_idcard.png";

        // 1. Generate the PDF
        PdfWriter writer = new PdfWriter(pdfPath);
        PdfDocument pdf = new PdfDocument(writer);
        Document doc = new Document(pdf, new PageSize(242.6f, 153f)); // Credit card size
        addIDCardContents(doc, student);  // Your custom content
        doc.close();

        // 2. Convert first page of PDF to PNG
//        try (PDDocument pdDoc = PDDocument.load(new File(pdfPath))) {
//            PDFRenderer pdfRenderer = new PDFRenderer(pdDoc);
//            BufferedImage bim = pdfRenderer.renderImageWithDPI(0, 300); // 300 DPI for good quality
//            ImageIO.write(bim, "png", new File(pngPath));
//        }

        return pdfPath;
 // You can return both if needed
    }

    /**
     * Generates and streams a student's ID card PDF to an OutputStream (e.g. HTTP response).
     */
    public void generateIDCardPdf(String regNo, OutputStream os) throws Exception {
        StudentIDRequest student = studentIDRequestRepository.findByRegNumber(regNo)
                .orElseThrow(() -> new RuntimeException("Student not found: " + regNo));

        PdfWriter writer = new PdfWriter(os);
        PdfDocument pdf = new PdfDocument(writer);
        Document doc = new Document(pdf, new PageSize(242.6f, 153f));

        doc.setMargins(5, 5, 5, 5);

        addIDCardContents(doc, student);

        doc.close();
//        Document doc = new Document(pdf, new PageSize(242.6f, 153f)); // 85.6mm x 53.98mm in points
//
//        doc.setMargins(5, 5, 5, 5)
    }

    /**
     * Shared method to add ID card contents (logo, text, photo, QR).
     */
    private static void addIDCardContents(Document doc, StudentIDRequest student) throws Exception {
        // University Logo
        Image logo = new Image(ImageDataFactory.create(UNIVERSITY_LOGO_PATH))
                .setWidth(40)
                .setHorizontalAlignment(HorizontalAlignment.CENTER);
        doc.add(logo);

        doc.add(new Paragraph("THE STATE UNIVERSITY OF ZANZIBAR")
                .setBold()
                .setFontSize(10)
                .setTextAlignment(TextAlignment.CENTER));

        doc.add(new Paragraph("Catalyst for Social Changes\nSTUDENT'S IDENTITY CARD")
                .setFontSize(8)
                .setTextAlignment(TextAlignment.CENTER));

        // Student photo
        if (student.getPhotoUrl() != null) {
            Image img = new Image(ImageDataFactory.create(student.getPhotoUrl()))
                    .setWidth(80)
                    .setHeight(100)
                    .setHorizontalAlignment(HorizontalAlignment.CENTER);
            doc.add(img);
        }

        // Details table
        Table table = new Table(UnitValue.createPercentArray(new float[]{30, 70}))
                .setWidth(UnitValue.createPercentValue(100));

        table.addCell(createCell("Name:"));
        table.addCell(createCell(student.getFullName()));

        table.addCell(createCell("Reg No:"));
        table.addCell(createCell(student.getRegNumber()));

        table.addCell(createCell("Prog:"));
        table.addCell(createCell(student.getCourse()));

        table.addCell(createCell("Year:"));
        table.addCell(createCell("2024/2025"));

        table.addCell(createCell("Valid Until:"));
        table.addCell(createCell("2024/2025"));

        doc.add(table);

        // Generate and add QR Code
        String qrPath = generateQRCode(student);
        Image qrImg = new Image(ImageDataFactory.create(qrPath))
                .setWidth(50)
                .setHeight(50)
                .setHorizontalAlignment(HorizontalAlignment.CENTER);
        doc.add(qrImg);
    }

    private static Cell createCell(String text) {
        return new Cell()
                .add(new Paragraph(text))
                .setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                .setFontSize(8);
    }

    private static String generateQRCode(StudentIDRequest student) throws Exception {
        // Generate QR containing all student ID info for scanning
        String qrText = "Name: " + student.getFullName() + "\n"
                + "RegNo: " + student.getRegNumber() + "\n"
                + "Course: " + student.getCourse() + "\n"
                + "Phone: " + student.getPhoneNo() + "\n"
                + "Email: " + student.getEmail();

        String path = "/home/gokyumi/work/idl_system/uploads/qrcodes/" + student.getRegNumber().replace("/", "_") + "_qr.png";

        QRCodeWriter writer = new QRCodeWriter();
        var bitMatrix = writer.encode(qrText, BarcodeFormat.QR_CODE, 150, 150);
        Path outputPath = FileSystems.getDefault().getPath(path);
        MatrixToImageWriter.writeToPath(bitMatrix, "PNG", outputPath);

        return path;
    }
}
