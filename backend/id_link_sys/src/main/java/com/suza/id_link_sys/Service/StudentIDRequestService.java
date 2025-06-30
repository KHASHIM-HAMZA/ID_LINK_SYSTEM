package com.suza.id_link_sys.Service;

import com.suza.id_link_sys.DTO.StudentIdRequestDTO;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Model.StudentIDRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class StudentIDRequestService {
    private final StudentIDRequestRepository studentIDRequestRepository;

    @Autowired
    public StudentIDRequestService(StudentIDRequestRepository studentIDRequestRepository) {
        this.studentIDRequestRepository = studentIDRequestRepository;
    }


    public List<StudentIDRequest> getAllStudentIDRequests() {
        return studentIDRequestRepository.findAll();
    }


    //from student
    public StudentIDRequest submitStudentIDRequest(StudentIdRequestDTO  dto) {
        // Check if student exists
        Optional<StudentIDRequest> existing = studentIDRequestRepository.findByRegNumber(dto.getRegNumber());
        StudentIDRequest request;

        if (existing.isPresent()) {
            request = existing.get();
            int count = request.getRequestCount() + 1;
            request.setRequestCount(count);

            if (count > 3 && (dto.getReportUrl() == null || dto.getReportUrl().isBlank())) {
                throw new RuntimeException("Exceeded 3 free requests. You must attach a report.");
            }

        } else {
            request = new StudentIDRequest();
            request.setRegNumber(dto.getRegNumber());
            request.setRequestCount(1);
        }

        request.setFullName(dto.getFullName());
        request.setRegNumber(dto.getRegNumber());
        request.setCourse(dto.getCourse());
        request.setYearOfStudy(dto.getYearOfStudy());
        request.setPhotoUrl(dto.getPhotoUrl());
        request.setEmail(dto.getEmail());

        //Set student values default
        request.setRequestDate(LocalDateTime.now());
        request.setStatus("Pending");
        request.setPrinted(false);
        request.setRequestCount(1);
        request.setQrCode("generate-later");

        return studentIDRequestRepository.save(request);
    }

    //to student
    public Optional<StudentIDRequest> getRequestByRegNo(String regNumber) {
        return studentIDRequestRepository.findByRegNumber(regNumber);
    }

    //Method of find student
    public StudentIDRequest findById(long id) {
        return studentIDRequestRepository.findById(id).get();
    }

    //save photo
    public String saveStudentPhoto(String regNumber, MultipartFile file) throws IOException {
        String folder = "/home/gokyumi/work/idl_system/uploads/photos";
        String fileName = regNumber.replace("/","_") + "_" + file.getOriginalFilename();
        Path filepath = Paths.get(folder, fileName);
        Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);
        // Update DB
        StudentIDRequest student = studentIDRequestRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));
        student.setPhotoUrl(filepath.toString());
        studentIDRequestRepository.save(student);


        return "Photo uploaded successfully: " + fileName;
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
