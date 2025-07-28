package com.suza.id_link_sys.Controller;


import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.StudentsRepository;
import com.suza.id_link_sys.Service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("api/admin")
public class adminController {
    @Autowired
    AdminService adminService;

    @Autowired
    StudentsRepository studentsRepository;


    @GetMapping(path = "/request")
    public List<StudentIDRequest> getPendingRequests() {
        return adminService.getPendingRequests();
    }

    @DeleteMapping("/remove-request/{regNumber}")
    public String deleteRequest(@PathVariable String regNumber) {
        adminService.deletePendingRequests(regNumber);
        return "success delete request: " + regNumber;
    }
/// update
    @PutMapping("/requests/{regNumber}")
    public StudentIDRequest updateStatus(
            @PathVariable String regNumber,
            @RequestBody Map<String, String> body) {

        String status = body.get("status");
        return adminService.updateStatus(regNumber, status);
    }

    // Approve endpoint
    @PutMapping("/requests/approve")
    public StudentIDRequest approveRequest(@RequestParam String regNumber) {
        return adminService.approveRequest(regNumber);
    }


    // Reject endpoint
    @PutMapping("/requests/{regNumber}/reject")
    public StudentIDRequest rejectRequest(@RequestParam String regNumber) {
        return adminService.rejectRequest(regNumber);
    }
//    @PostMapping("/approve-report/{id}")
//    public String approveReport(@PathVariable long id) {
//        studentService.approveReport(id);
//        return "Report approved and status updated.";
//    }

    @GetMapping("/approved")
    public List<StudentIDRequest> getApprovedRequests() {
        return adminService.getApprovedIds();
    }


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
