package com.suza.id_link_sys.Service;


import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.VerticalAlignment;
import org.springframework.stereotype.Service;

import java.io.FileNotFoundException;

@Service
public class testpdf {

    public void generateTestPdf() throws FileNotFoundException {
        String path = "";
        PdfWriter pdfWriter = new PdfWriter(path);
        PdfDocument pdf= new PdfDocument(pdfWriter);
        Document  document = new Document(pdf, new PageSize(PageSize.A4));

        float col = 30f;
        float columnWidth[] = {col,col};

        Table table = new Table(columnWidth);

        table.setBackgroundColor(ColorConstants.YELLOW)
                        .setFontColor(ColorConstants.WHITE);


        table.addCell("HELLO WORLD")
                        .setTextAlignment(TextAlignment.CENTER)
                                .setVerticalAlignment(VerticalAlignment.MIDDLE)
                                        .setFontSize(20)
                                                .setMarginBottom(12f)
                                                        .setMarginBottom(12f);
        table.addCell("I am dedicate my thanks to GOD,\n for give me a new blessed day");


        document.add(table);
    }
}
