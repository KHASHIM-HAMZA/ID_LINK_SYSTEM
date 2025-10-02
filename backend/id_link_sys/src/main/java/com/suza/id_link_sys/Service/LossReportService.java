package com.suza.id_link_sys.Service;

import com.suza.id_link_sys.Model.LossReport;
import com.suza.id_link_sys.Repository.LossReportRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

@Service
public class LossReportService {

    @Autowired
    private LossReportRepository repository;

    private final String UPLOAD_DIR = "./uploads/loss_reports/";

    public LossReport saveReport(String regNumber, String description, MultipartFile pdfFile) throws IOException {

        // Ensure upload directory exists
        Files.createDirectories(Paths.get(UPLOAD_DIR));

        LossReport report = new LossReport();
        report.setRegNumber(regNumber);
        report.setDescription(description);

        if (pdfFile != null && !pdfFile.isEmpty()) {
            String filename = regNumber + "_" + System.currentTimeMillis() + "_" + pdfFile.getOriginalFilename();
            String filePath = UPLOAD_DIR + filename;
            pdfFile.transferTo(new File(filePath));
            report.setPdfPath(filePath);
        }

        return repository.save(report);
    }
}
