package com.suza.id_link_sys.Controller;


import com.suza.id_link_sys.DTO.StudentIdRequestDTO;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.StudentsRepository;
import com.suza.id_link_sys.Service.StudentIDRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;

@RestController
@RequestMapping("/api/student")
public class StudentController {
    @Autowired
    private final StudentIDRequestService studentIDRequestService;

    @Autowired
    StudentsRepository studentsRepository;

    @Autowired
    public StudentController(StudentIDRequestService studentIDRequestService) {
        this.studentIDRequestService = studentIDRequestService;
    }


    @PostMapping(value = "/request-with-photo", consumes = {"multipart/form-data"})
    public StudentIDRequest submitRequestWithPhoto(
            @RequestParam("fullName") String fullName,
            @RequestParam("regNumber") String regNumber,
            @RequestParam("course") String course,
            @RequestParam("yearOfStudy") int yearOfStudy,
            @RequestParam("email") String email,
            @RequestParam("phoneNo") int phoneNo,
            @RequestPart("file") MultipartFile file) throws Exception {

        // 1. Create DTO
        StudentIdRequestDTO dto = new StudentIdRequestDTO();
        dto.setFullName(fullName);
        dto.setRegNumber(regNumber);
        dto.setCourse(course);
        dto.setYearOfStudy(yearOfStudy);
        dto.setEmail(email);
        dto.setPhoneNo(phoneNo);

        // 2. Submit request (save to DB)
        StudentIDRequest savedRequest = studentIDRequestService.submitStudentIDRequest(dto);

        // 3. Save photo file
        String photoUrl = studentIDRequestService.saveStudentPhoto(regNumber, file);

        // 4. Update savedRequest with photo URL
        savedRequest.setPhotoUrl(photoUrl);

        // 5. Save updated request to DB
        return studentIDRequestService.save(savedRequest);
    }


    //update info


    @GetMapping("/profile/{regNumber}")
    public Students getStudentProfile(@RequestParam String regNumber) {
        return studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }



    @GetMapping("/status/{regNumber}")
    public StudentIDRequest getStatus(@PathVariable String regNumber) {
        return studentIDRequestService.getRequestByRegNo(regNumber).orElse(null);
    }
//    @PostMapping("/uploadPhoto/{regNumber}")
//    public String uploadPhoto(@PathVariable String regNumber, @RequestParam("file") MultipartFile file) throws Exception {
//        return studentsRepository.saveStudentPhoto(regNumber, file);
//    }
    //update info
    @PutMapping("/update/{regNumber}")
    public Students updateProfile(
            @PathVariable String regNumber,
            @RequestParam("email") String email,
            @RequestParam("phoneNo") int phoneNo,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) throws Exception {
        Students student = studentsRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        student.setEmail(email);
        student.setPhoneNo(phoneNo);

        // Save new photo if provided
        if (file != null && !file.isEmpty()) {
            String uploadDir = "/home/gokyumi/work/idl_system/uploads/photos/"; // change to your uploads path
            String filename = regNumber + "_profile_" + file.getOriginalFilename();
            File dest = new File(uploadDir + filename);
            file.transferTo(dest);

            String photoUrl = "http://localhost:8082/api/student/uploadPhoto/{regNumber}" + filename;
            student.setPhotoUrl(photoUrl);
        }

        return studentsRepository.save(student);
    }
//
//    @PostMapping("/request")
//    public StudentIDRequest submitRequest(@RequestBody StudentIdRequestDTO dto) {
//        return studentIDRequestService.submitStudentIDRequest(dto);
//    }



}
