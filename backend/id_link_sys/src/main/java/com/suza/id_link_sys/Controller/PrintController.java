package com.suza.id_link_sys.Controller;

import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Service.PDFService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/print")
@PreAuthorize("hasRole('ADMIN')") // Require ADMIN role
public class PrintController {

    @Autowired
    private StudentIDRequestRepository requestRepo;

    @Autowired
    PDFService pdfService;

    // ✅GET all approved but unprinted IDs
    @GetMapping("/approved")
    public List<String> getApprovedButUnprintedIDs() {
        return requestRepo.findByStatusAndPrinted("Approved", false)
                .stream()
                .map(request -> request.getStudent().getRegNumber())
                .toList();
    }

    // ✅ PUT to mark an ID as printed after successful printing
    @PutMapping("/mark-printed")
    public ResponseEntity<Map<String, Object>> markAsPrinted(@RequestParam String regNumber) {
        StudentIDRequest studentRequest = requestRepo.findByStudentRegNumber(regNumber)
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Student not found: " + regNumber));

        Map<String, Object> response = new HashMap<>();
        try {
            PDFService.generateStudentIDCard(studentRequest);
            studentRequest.setPrinted(true); // Marked as printed
            requestRepo.save(studentRequest);

            response.put("status", "success");
            response.put("message", "Printing ID Complete");
            response.put("regNumber", regNumber);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error during approve process: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }

        return ResponseEntity.ok(response);
    }


    // ✅ Endpoint for admin to view all approved & printed IDs as PDFs
    @GetMapping("/all-approved")
    public List<StudentIDRequest> getAllApprovedAndPrintedIDs() {
        return requestRepo.findByStatusAndPrinted("Approved", true);
    }

    // ✅ Endpoint to view/generate a specific student's ID PDF inline
    @GetMapping("/idcard")
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