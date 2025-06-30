package com.suza.id_link_sys.Controller;


import com.suza.id_link_sys.DTO.StudentIdRequestDTO;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Service.StudentIDRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/student")
public class StudentController {

    private final StudentIDRequestService studentIDRequestService;

    @Autowired
    public StudentController(StudentIDRequestService studentIDRequestService) {
        this.studentIDRequestService = studentIDRequestService;
    }

    @PostMapping("/uploadPhoto/{regNumber}")
    public String uploadPhoto(@PathVariable String regNumber, @RequestParam("file") MultipartFile file) throws Exception {
        return studentIDRequestService.saveStudentPhoto(regNumber, file);
    }

    @PostMapping("/request")
    public StudentIDRequest submitRequest(@RequestBody StudentIdRequestDTO dto) {
        return studentIDRequestService.submitStudentIDRequest(dto);
    }

    @GetMapping("/status/{regNumber}")
    public StudentIDRequest getStatus(@PathVariable String regNumber) {
        return studentIDRequestService.getRequestByRegNo(regNumber).orElse(null);
    }

}
