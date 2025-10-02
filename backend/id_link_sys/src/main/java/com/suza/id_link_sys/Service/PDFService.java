package com.suza.id_link_sys.Service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.qrcode.QRCodeWriter;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.colors.DeviceRgb;
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
        String fileName = student.getStudent().getRegNumber().replace("/", "_");
        String pdfPath = "/home/gokyumi/work/idl_system/uploads/idcards/" + fileName + "_idcard.pdf";

        PdfWriter writer = new PdfWriter(pdfPath);
        PdfDocument pdf = new PdfDocument(writer);
        Document doc = new Document(pdf, new PageSize(153f, 242.6f)); // Portrait: height 153mm, width 242.6mm
        doc.setMargins(1, 1, 1, 1); // Minimal margins

        addIDCardContents(doc, student);
        doc.close();

        return pdfPath;
    }

    /**
     * Generates and streams a student's ID card PDF to an OutputStream (e.g. HTTP response).
     */
    public void generateIDCardPdf(String regNo, OutputStream os) throws Exception {
        StudentIDRequest student = studentIDRequestRepository.findByStudentRegNumber(regNo)
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Student not found: " + regNo));

        PdfWriter writer = new PdfWriter(os);
        PdfDocument pdf = new PdfDocument(writer);
        Document doc = new Document(pdf, new PageSize(153f, 242.6f)); // Portrait: height 153mm, width 242.6mm
        doc.setMargins(1, 1, 1, 1); // Minimal margins

        addIDCardContents(doc, student);
        doc.close();
    }

    /**
     * Shared method to add ID card contents (logo, text, photo, QR).
     */
    private static void addIDCardContents(Document doc, StudentIDRequest student) throws Exception {
        // Wave background
        Paragraph waveBackground = new Paragraph()
                .setBackgroundColor(new DeviceRgb(173, 216, 230)) // LightSkyBlue
                .setHeight(20f)
                .setWidth(153f)
                .setMarginBottom(5f); // Space below wave
        doc.add(waveBackground);

        // University Logo
        Image logo = new Image(ImageDataFactory.create(UNIVERSITY_LOGO_PATH))
                .setWidth(30f)
                .setHorizontalAlignment(HorizontalAlignment.CENTER);
        doc.add(logo);

        // University and Card Title
        doc.add(new Paragraph("THE STATE UNIVERSITY OF ZANZIBAR")
                .setBold()
                .setFontSize(5)
                .setTextAlignment(TextAlignment.CENTER));
        doc.add(new Paragraph("Catalyst for Social Changes\nSTUDENT'S IDENTITY CARD")
                .setFontSize(4)
                .setTextAlignment(TextAlignment.CENTER));

        // Student photo
        if (student.getPhotoPath() != null) {
            Image img = new Image(ImageDataFactory.create(student.getPhotoPath().trim()))
                    .setWidth(42f)
                    .setHeight(40f)
                    .setHorizontalAlignment(HorizontalAlignment.CENTER);
            doc.add(img);
        }

        // Details table with minimal gap
        Table table = new Table(UnitValue.createPercentArray(new float[]{40, 60})) // Adjusted for tighter fit
                .setWidth(UnitValue.createPercentValue(100))
                .setFontSize(4)
                .setHorizontalAlignment(HorizontalAlignment.CENTER); // Center the table

        table.addCell(createCell("Name:").setTextAlignment(TextAlignment.CENTER));
        table.addCell(createCell(student.getStudent().getFullName().toUpperCase()));

        table.addCell(createCell("Reg No:").setTextAlignment(TextAlignment.CENTER));
        table.addCell(createCell(student.getStudent().getRegNumber()));

        table.addCell(createCell("Prog:").setTextAlignment(TextAlignment.CENTER));
        table.addCell(createCell(student.getStudent().getCourse().toUpperCase()));

        table.addCell(createCell("Year:").setTextAlignment(TextAlignment.CENTER));
        table.addCell(createCell(String.valueOf(student.getStudent().getYear())));

        table.addCell(createCell("Valid Until:").setTextAlignment(TextAlignment.CENTER));
        table.addCell(createCell("2024/2025"));

        doc.add(table);

        // Generate and add QR Code with padding
        String qrPath = generateQRCode(student);
        Image qrImg = new Image(ImageDataFactory.create(qrPath))
                .setWidth(18f)
                .setHeight(18f)
                .setHorizontalAlignment(HorizontalAlignment.RIGHT)
                .setMarginRight(10f)
                .setPaddingRight(15f); // Padding from the right border
        doc.add(qrImg);
    }

    private static Cell createCell(String text) {
        return new Cell()
                .add(new Paragraph(text))
                .setBorder(com.itextpdf.layout.borders.Border.NO_BORDER)
                .setFontSize(4);
    }

    private static String generateQRCode(StudentIDRequest student) throws Exception {
        String qrText = "Name: " + student.getStudent().getFullName() + "\n"
                + "RegNo: " + student.getStudent().getRegNumber() + "\n"
                + "Course: " + student.getStudent().getCourse() + "\n"
                + "Phone: " + student.getStudent().getPhoneNo() + "\n"
                + "Email: " + student.getStudent().getEmail();

        String path = "/home/gokyumi/work/idl_system/uploads/qrcodes/" + student.getStudent().getRegNumber().replace("/", "_") + "_qr.png";

        QRCodeWriter writer = new QRCodeWriter();
        var bitMatrix = writer.encode(qrText, BarcodeFormat.QR_CODE, 150, 150);
        Path outputPath = FileSystems.getDefault().getPath(path);
        MatrixToImageWriter.writeToPath(bitMatrix, "PNG", outputPath);

        return path;
    }
}