package com.suza.id_link_sys.Controller;


import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/admin")
public class adminController {
    @Autowired
    AdminService adminService;


    @GetMapping(path = "/request")
    public List<StudentIDRequest> getPendingRequests() {
        return adminService.getPendingRequests();
    }

    @DeleteMapping("/remove-request/{regNumber}")
    public String deleteRequest(@PathVariable String regNumber) {
        adminService.deletePendingRequests(regNumber);
        return "success delete request: " + regNumber;
    }

    @PutMapping("/requests/{regNumber}")
    public StudentIDRequest updateStatus(@PathVariable String regNumber, @RequestParam(required = false) String status) {
        return adminService.updateStatus(regNumber, status);
    }

//    @PostMapping("/approve-report/{id}")
//    public String approveReport(@PathVariable long id) {
//        studentService.approveReport(id);
//        return "Report approved and status updated.";
//    }


    //MESSAGE<send>
    @PostMapping("/messages/send")
    public Message sendMessage(@RequestBody Message message) {
        return adminService.sendMessage(message);
    }

    //<receive>
    @GetMapping("/messages/incoming")
    public List<Message> getNewMessages(Message message) {
        return adminService.incomingMessages(message);
    }


}
