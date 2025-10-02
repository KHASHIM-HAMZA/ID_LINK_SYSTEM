package com.suza.id_link_sys.Service;

import com.suza.id_link_sys.DTO.IDStatusDTO;
import com.suza.id_link_sys.DTO.StudentIdRequestDTO;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class StudentIDRequestService {
    private final StudentIDRequestRepository studentIDRequestRepository;
    private final StudentsRepository studentsRepository;

    @Autowired
    public StudentIDRequestService(StudentIDRequestRepository studentIDRequestRepository, StudentsRepository studentsRepository) {
        this.studentIDRequestRepository = studentIDRequestRepository;
        this.studentsRepository = studentsRepository;
    }

    public List<StudentIDRequest> getAllStudentIDRequests() {
        return studentIDRequestRepository.findAll();
    }

    @Transactional
    public StudentIDRequest submitStudentIDRequest(StudentIdRequestDTO dto, MultipartFile photoFile, MultipartFile reportFile) throws IOException {
        // Validate student
        Students student = studentsRepository.findByRegNumber(dto.getRegNumber())
                .orElseThrow(() -> new RuntimeException("Student not found with regNumber: " + dto.getRegNumber()));

        // Check request count and report
        int requestCount = student.getRequestCount();
        if (requestCount >= 3 && (reportFile == null || reportFile.isEmpty())) {
            throw new RuntimeException("Exceeded 3 free requests. A report is required.");
        }

        // Save report if provided
        String reportUrl = null;
        if (reportFile != null && !reportFile.isEmpty()) {
            reportUrl = saveReport(dto.getRegNumber(), reportFile);
        }

        // Save photo for request
        String photoPath = saveRequestPhoto(dto.getRegNumber(), photoFile);

        // Create new ID request with fields from student
        StudentIDRequest request = new StudentIDRequest();
        request.setStudent(student);
        request.setQrCode(dto.getQrCode() != null ? dto.getQrCode() : "generate-later");
        request.setRequestDate(LocalDateTime.now());
        request.setStatus("Pending");
        request.setPrinted(false);
        request.setYearOfStudy(student.getYear());
        request.setPhoneNo(student.getPhoneNo());
        request.setEmail(student.getEmail());
        request.setCourse(student.getCourse());
        request.setFullName(student.getFullName());
        request.setReportUrl(reportUrl);
        request.setPhotoPath(photoPath);
        request.setRequestCount(student.getRequestCount() + 1);

        // Save request first
        StudentIDRequest savedRequest = studentIDRequestRepository.save(request);

        // Increment request count only after successful request save
        student.setRequestCount(requestCount + 1);
        studentsRepository.save(student);

        return savedRequest;
    }

    public Optional<StudentIDRequest> getRequestByRegNo(String regNumber) {
        return studentIDRequestRepository.findByStudentRegNumber(regNumber).stream().findFirst();
    }

    public String saveRequestPhoto(String regNumber, MultipartFile file) throws IOException {
        String folder = "/home/gokyumi/work/idl_system/uploads/request_photos";
        Files.createDirectories(Paths.get(folder));

        String safeReg = regNumber.replace("/", "_");
        String fileName = safeReg + "_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
        Path filepath = Paths.get(folder, fileName);

        Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

        // ⬅️ return the ABSOLUTE PATH for DB
        return filepath.toAbsolutePath().toString();
    }


    public String saveStudentPhoto(String regNumber, MultipartFile file) throws IOException {
        String folder = "/home/gokyumi/work/idl_system/uploads/photos";
        Files.createDirectories(Paths.get(folder));

        String fileName = regNumber.replace("/", "_") + "_" + "_" + file.getOriginalFilename();
        Path filepath = Paths.get(folder, fileName);
        Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

        // ✅ Save public URL in DB
        String photoUrl = "http://localhost:8080/uploads/photos/" + fileName;
        Students student = studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));
        student.setPhotoUrl(photoUrl);
        studentsRepository.save(student);

        return photoUrl;
    }


    public String saveReport(String regNumber, MultipartFile file) throws IOException {
        String folder = "/home/gokyumi/work/idl_system/uploads/reports";
        Files.createDirectories(Paths.get(folder));
        String fileName = regNumber.replace("/", "_") + "_report_" + System.currentTimeMillis() + ".pdf";
        Path filepath = Paths.get(folder, fileName);

        Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

        return "http://localhost:8080/uploads/reports/" + fileName;
    }

    public StudentIDRequest save(StudentIDRequest request) {
        return studentIDRequestRepository.save(request);
    }

    public IDStatusDTO getIDStatus(String regNumber) {
        // Find student
        Students student = studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found with reg number: " + regNumber));

        // Get latest ID request
        StudentIDRequest latestRequest = studentIDRequestRepository
                .findTopByStudentOrderByRequestDateDesc(student)
                .orElseThrow(() -> new RuntimeException("No ID request found for student: " + regNumber));

        // Map to DTO
        return mapToDTO(latestRequest, student);
    }

    private IDStatusDTO mapToDTO(StudentIDRequest request, Students student) {
        IDStatusDTO dto = new IDStatusDTO();
        dto.setStatus(request.getStatus());
        dto.setRequestDate(request.getRequestDate());

        if ("Printed".equalsIgnoreCase(request.getStatus())) {
            dto.setCompletionDate(request.getRequestDate().plusDays(3)); // Example calculation
        }

        IDStatusDTO.StudentDetailsDTO studentDetails = new IDStatusDTO.StudentDetailsDTO();
        studentDetails.setFullName(student.getFullName());
        studentDetails.setCourse(student.getCourse());
        studentDetails.setYearOfStudy(student.getYear());
        studentDetails.setPhotoUrl(student.getPhotoUrl());

        dto.setStudentDetails(studentDetails);

        return dto;
    }
//    public void generatePDFandPrint(StudentIDRequest student) throws Exception {
//        pdfService.generateStudentIDCard(student);
//
//        // Print immediately after generating PDF
//        String pdfPath = "/home/idl_system/uploads/idcards/" + student.getRegNumber().replace("/", "_") + ".pdf";
//        ProcessBuilder pb = new ProcessBuilder("lp", pdfPath);
//        pb.start();
//    }
//    //Remove
//    public StudentIDRequest DeleteByRegNo(String regNumber) {
//        return studentIDRequestRepository.delete;
//    }
}
