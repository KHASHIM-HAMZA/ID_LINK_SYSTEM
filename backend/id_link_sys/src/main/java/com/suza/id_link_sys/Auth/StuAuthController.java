package com.suza.id_link_sys.Auth;

import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.nio.file.Files;
import java.util.Optional;


@RestController
@RequestMapping("/api/student")
public class StuAuthController {
    @Autowired
    StudentsRepository studentsRepository;


    @Autowired
    private StudentIDRequestRepository requestRepo;

    private static final String BASE_PATH = "/home/gokyumi/work/idl_system/uploads/idcards/";


    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Students student) {
        Optional<Students> dbStudent = studentsRepository.findByRegNumber(student.getRegNumber());

        if (dbStudent.isPresent()) {
            if (dbStudent.get().getPassword().equals(student.getPassword())) {
                return ResponseEntity.ok(dbStudent.get());
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("invalid password, try again!");
            }
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("student not found");
        }
    }


    // ✅ Endpoint to return PDF if ID is printed
    @GetMapping("/view/{regNumber}")
    public void getStudentIDCardPdf(@PathVariable String regNumber, HttpServletResponse response) throws Exception {
        StudentIDRequest student = requestRepo.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (!student.getStatus().equals("Approved") || !student.isPrinted()) {
            throw new RuntimeException("ID not available yet");
        }

        String safeReg = regNumber.replace("/", "_");
        File file = new File(BASE_PATH + safeReg + "_idcard.pdf");

        if (!file.exists()) {
            throw new RuntimeException("PDF not found for: " + regNumber);
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=" + safeReg + "_idcard.pdf");
        Files.copy(file.toPath(), response.getOutputStream());
    }

    // ✅ Endpoint to return image version (if available)
    @GetMapping("/image/{regNumber}")
    public void getStudentIDCardImage(@PathVariable String regNumber, HttpServletResponse response) throws Exception {
        StudentIDRequest student = requestRepo.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (!student.getStatus().equals("Approved") || !student.isPrinted()) {
            throw new RuntimeException("ID not available yet");
        }

        String safeReg = regNumber.replace("/", "_");
        File file = new File(BASE_PATH + safeReg + ".png");

        if (!file.exists()) {
            throw new RuntimeException("Image not found for: " + regNumber);
        }

        response.setContentType("image/png");
        response.setHeader("Content-Disposition", "inline; filename=" + safeReg + ".png");
        Files.copy(file.toPath(), response.getOutputStream());
    }


}
