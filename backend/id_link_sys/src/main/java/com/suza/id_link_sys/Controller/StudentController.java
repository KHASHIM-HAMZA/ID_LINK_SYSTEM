package com.suza.id_link_sys.Controller;

import com.suza.id_link_sys.DTO.ChangePasswordDTO;
import com.suza.id_link_sys.DTO.IDStatusDTO;
import com.suza.id_link_sys.DTO.StudentIdRequestDTO;
import com.suza.id_link_sys.Model.LossReport;
import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.MessageRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import com.suza.id_link_sys.Service.LossReportService;
import com.suza.id_link_sys.Service.MessageService;
import com.suza.id_link_sys.Service.StudentIDRequestService;
import com.suza.id_link_sys.Service.StudentService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
//@PreAuthorize("hasRole('STUDENT')")
public class StudentController {
    private final StudentIDRequestService studentIDRequestService;
    private final StudentsRepository studentsRepository;
    private final StudentService studentService;

    @Autowired
    private LossReportService service;

    @Autowired
    MessageRepository messageRepository;

    @Autowired
    public StudentController(StudentIDRequestService studentIDRequestService, StudentsRepository studentsRepository, StudentService studentService) {
        this.studentIDRequestService = studentIDRequestService;
        this.studentsRepository = studentsRepository;
        this.studentService  = studentService;
    }

    @Autowired
    private MessageService messageService;

    @PostMapping(value = "/request-with-photo", consumes = {"multipart/form-data"})
    public StudentIDRequest submitRequestWithPhoto(
            @RequestParam("regNumber") String regNumber,
            @RequestParam(value = "qrCode", defaultValue = "generate-later") String qrCode,
            @RequestParam(value = "fullName", required = false) String fullName,
            @RequestParam(value = "course", required = false) String course,
            @RequestParam(value = "yearOfStudy", required = false) Integer yearOfStudy,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "phoneNo", required = false) Integer phoneNo,
            @RequestPart(value = "reportFile", required = false) MultipartFile reportFile,
            @RequestPart("file") MultipartFile file) throws IOException {
        // Secure check: Ensure regNumber matches authenticated user
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentRegNumber = authentication.getName(); // Assuming username is regNumber
        if (!currentRegNumber.equals(regNumber)) {
            throw new RuntimeException("You can only submit requests for your own registration number.");
        }

        Integer effectiveYearOfStudy = yearOfStudy != null ? yearOfStudy : 0;

        StudentIdRequestDTO dto = new StudentIdRequestDTO();
        dto.setRegNumber(regNumber);
        dto.setQrCode(qrCode);
        dto.setFullName(fullName);
        dto.setCourse(course);
        dto.setYearOfStudy(effectiveYearOfStudy);
        dto.setEmail(email);
        dto.setPhoneNo(phoneNo);

        // Submit request with files
        return studentIDRequestService.submitStudentIDRequest(dto, file, reportFile);
    }

    @GetMapping("/profile")
    public Students getStudentProfile(@RequestParam String regNumber) {
        return studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    @GetMapping("/status")
    public StudentIDRequest getStatus(@RequestParam String regNumber) {
        return studentIDRequestService.getRequestByRegNo(regNumber)
                .orElse(null);
    }

    @PostMapping("/update")
    public Students updateProfile(
            @RequestParam String regNumber,
            @RequestParam("email") String email,
            @RequestParam("phoneNo") int phoneNo,
            @RequestPart(value = "file", required = false) MultipartFile file) throws IOException {
        Students student = studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        student.setEmail(email);
        student.setPhoneNo(phoneNo);

        if (file != null && !file.isEmpty()) {
            studentIDRequestService.saveStudentPhoto(regNumber, file);
        }

        return studentsRepository.save(student);
    }

    @GetMapping("/uploads/photos")
    public void getPhoto(@RequestParam String regNumber, HttpServletResponse response) throws IOException {
        Students student = studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (student.getPhotoUrl() == null) {
            response.sendError(HttpStatus.NOT_FOUND.value());
            return;
        }

        File file = new File(student.getPhotoUrl());
        if (!file.exists()) {
            response.sendError(HttpStatus.NOT_FOUND.value());
            return;
        }

        response.setContentType(Files.probeContentType(file.toPath()));
        Files.copy(file.toPath(), response.getOutputStream());
    }

    @GetMapping("/photo")
    public ResponseEntity<Map<String, String>> getStudentPhoto(@RequestParam String regNumber) {
        Students student = studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (student.getPhotoUrl() == null || student.getPhotoUrl().isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // ✅ Return the actual public URL saved in DB
        return ResponseEntity.ok(Map.of("photoUrl", student.getPhotoUrl()));
    }


    @PostMapping("/messages")
    public ResponseEntity<Message> sendMessage(@RequestBody Message message) {
        // Get currently logged-in student registration number
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentRegNumber = authentication.getName(); // assumes username = regNumber

        // Set the student_reg_number before saving
        message.setStudentRegNumber(currentRegNumber);

        Message saved = messageRepository.save(message);
        return ResponseEntity.ok(saved);
    }
    @GetMapping("/id-status")
    public ResponseEntity<IDStatusDTO> getIDStatus(
            @RequestParam String regNumber) {

        IDStatusDTO statusDTO = studentIDRequestService.getIDStatus(regNumber);
        return ResponseEntity.ok(statusDTO);
    }



    @PostMapping("/change-password")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordDTO dto) {
        boolean success = studentService.changePassword(dto);

        if (!success) {
            return ResponseEntity.badRequest().body("Invalid current password or student not found");
        }

        return ResponseEntity.ok("Password changed successfully");
    }
//    @PostMapping("/request")
//    public StudentIDRequest submitRequest(@RequestBody StudentIdRequestDTO dto) {
//        return studentIDRequestService.submitStudentIDRequest(dto);
//    }


    @PostMapping("/loss-report")
    public ResponseEntity<?> submitLossReport(
            @RequestParam String regNumber,
            @RequestParam String description,
            @RequestParam(required = false) MultipartFile pdf
    ) {
        try {
            LossReport report = service.saveReport(regNumber, description, pdf);
            return ResponseEntity.ok(report);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Failed to submit report: " + e.getMessage());
        }
    }

    }