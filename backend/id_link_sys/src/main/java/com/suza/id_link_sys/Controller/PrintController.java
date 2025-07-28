package com.suza.id_link_sys.Controller;

import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Service.PDFService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.nio.file.Files;
import java.util.List;

@RestController
@RequestMapping("/api/print")
public class PrintController {

    @Autowired
    private StudentIDRequestRepository requestRepo;

    @Autowired
    PDFService pdfService;

    // ✅ GET all approved but unprinted IDs
    @GetMapping("/approved")
    public List<String> getApprovedButUnprintedIDs() {
        return requestRepo.findByStatusAndPrinted("Approved", false)
                .stream()
                .map(StudentIDRequest::getRegNumber)
                .toList();
    }

    // ✅ PUT to mark an ID as printed after successful printing
    @PutMapping("/mark-printed/{regNumber}")
    public String markAsPrinted(@PathVariable String regNumber) {
        StudentIDRequest student = requestRepo.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found: " + regNumber));
        try {
            PDFService.generateStudentIDCard(student);
            student.setPrinted(true); // Printed will be marked true by Bash script after printing
        } catch (Exception e) {
            throw new RuntimeException("Error during approve process: " + e.getMessage());
        }
        requestRepo.save(student);

        return "Printing ID Complete and Marked " + regNumber + " as printed";
    }


    // ✅ Endpoint for admin to view all approved & printed IDs as PDFs
    @GetMapping("/all-approved")
    public List<StudentIDRequest> getAllApprovedAndPrintedIDs() {
        return requestRepo.findByStatusAndPrinted("Approved", true);
    }

    // ✅ Endpoint to view/generate a specific student's ID PDF inline
    @GetMapping("/idcard/{regNumber}")
    public void generateIDCard(@RequestParam String regNumber, HttpServletResponse response) throws Exception {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=" + regNumber.replace("/", "_") + "_ID.pdf");
        pdfService.generateIDCardPdf(regNumber, response.getOutputStream());
    }

    // View PDF from disk by regNumber
    @GetMapping("/view")
    public void viewPdf(@RequestParam String regNumber, HttpServletResponse response) throws Exception {
        String filePath = "/home/gokyumi/work/idl_system/uploads/idcards/" + regNumber.replace("/", "_") + "_idcard.pdf";

        File file = new File(filePath);
        if (!file.exists()) throw new RuntimeException("PDF not found: " + regNumber);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=" + file.getName());
        Files.copy(file.toPath(), response.getOutputStream());
    }


}
