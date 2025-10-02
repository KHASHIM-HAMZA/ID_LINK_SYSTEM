package com.suza.id_link_sys.Auth;

import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import com.suza.id_link_sys.Security.JwtUtil;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/student")
public class StuAuthController {
    @Autowired
    private StudentsRepository studentsRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private StudentIDRequestRepository requestRepo;

    private static final String BASE_PATH = "/home/gokyumi/work/idl_system/uploads/idcards/";

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Students student) {
        Optional<Students> dbStudent = studentsRepository.findByRegNumber(student.getRegNumber());

        if (dbStudent.isPresent() && dbStudent.get().getPassword().equals(student.getPassword())) {
            String token = jwtUtil.generateToken(dbStudent.get().getRegNumber(), "STUDENT");

            return ResponseEntity.ok(
                    Map.of(
                            "regNumber", dbStudent.get().getRegNumber(),
                            "role", "STUDENT",
                            "token", token,
                            "message", "Login successful",
                            "userData", dbStudent.get()
                    )
            );
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }
    }

    @GetMapping("/view")
    public void getStudentIDCardPdf(@RequestParam String regNumber, HttpServletResponse response) throws Exception {
        Optional<StudentIDRequest> studentRequest = requestRepo.findByStudentRegNumber(regNumber)
                .stream()
                .filter(req -> req.getStatus().equals("Approved") && req.isPrinted())
                .findFirst();

        if (studentRequest.isEmpty()) {
            throw new RuntimeException("ID not available yet for: " + regNumber);
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

    @GetMapping("/image")
    public void getStudentIDCardImage(@RequestParam String regNumber, HttpServletResponse response) throws Exception {
        Optional<StudentIDRequest> studentRequest = requestRepo.findByStudentRegNumber(regNumber)
                .stream()
                .filter(req -> req.getStatus().equals("Approved") && req.isPrinted())
                .findFirst();

        if (studentRequest.isEmpty()) {
            throw new RuntimeException("ID not available yet for: " + regNumber);
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

    @GetMapping("/verify")
    public ResponseEntity<?> verifyStudent(@RequestParam String regNumber) {
        return studentsRepository.findByRegNumber(regNumber)
                .map(student -> {
                    Map<String, Object> response = new HashMap<>();
                    response.put("fullName", student.getFullName());
                    response.put("email", student.getEmail());
                    response.put("phoneNo", student.getPhoneNo());
                    response.put("course", student.getCourse());
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.status(404).body(
                        Map.of("error", "Student not found")
                ));
    }
}