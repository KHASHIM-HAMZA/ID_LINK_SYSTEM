package com.suza.id_link_sys.Controller;

import com.suza.id_link_sys.Service.StudentIDRequestService;
import com.suza.id_link_sys.Model.StudentIDRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/id-request")
public class StudentIDRequestController {
    private StudentIDRequestService studentIDRequestService;

    @Autowired
    public StudentIDRequestController(StudentIDRequestService studentIDRequestService) {
        this.studentIDRequestService = studentIDRequestService;
    }

    @GetMapping
    public List<StudentIDRequest> getStudentIDRequest() {
        return studentIDRequestService.getAllStudentIDRequests();
    }

//    @PostMapping
//    public void createStudentIDRequest(@RequestBody StudentIDRequest studentIDRequest) {
//        studentIDRequestService.createNewRequest(studentIDRequest);
//    }
}