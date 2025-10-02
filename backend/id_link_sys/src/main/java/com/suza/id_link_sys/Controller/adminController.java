package com.suza.id_link_sys.Controller;

import com.suza.id_link_sys.DTO.StudentIdRequestViewDTO;
import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.StudentsRepository;
import com.suza.id_link_sys.Service.AdminService;
import com.suza.id_link_sys.Service.MessageService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')") // All methods in this controller require ADMIN role
public class adminController {
    @Autowired
    AdminService adminService;

    @Autowired
    private MessageService messageService;
    
    @Autowired
    StudentsRepository studentsRepository;

    @GetMapping("/requests")
    public List<StudentIdRequestViewDTO> getPendingRequests(HttpServletRequest request) {
        String baseUrl = ServletUriComponentsBuilder.fromRequestUri(request)
                .replacePath(null)
                .build()
                .toUriString(); // e.g., http://localhost:8080

        return adminService.getPendingRequests().stream()
                .map(e -> StudentIdRequestViewDTO.fromEntity(e, baseUrl))
                .toList();
    }



    @DeleteMapping("/remove-request")
    public String deleteRequest(@RequestParam String regNumber) {
        adminService.deletePendingRequests(regNumber);
        return "success delete request: " + regNumber;
    }

    @PutMapping("/requests/update")
    public StudentIDRequest updateStatus(
            @RequestParam String regNumber,
            @RequestParam String status) {
        return adminService.updateStatus(regNumber, status);
    }

    // Approve endpoint
    @PutMapping("/requests/approve")
    public StudentIDRequest approveRequest(@RequestParam String regNumber) {
        return adminService.approveRequest(regNumber);
    }

    // Reject endpoint
    @PutMapping("/requests/reject")
    public StudentIDRequest rejectRequest(@RequestParam String regNumber) {
        return adminService.rejectRequest(regNumber);
    }

    @GetMapping("/approved")
    public List<StudentIDRequest> getApprovedRequests() {
        return adminService.getApprovedIds();
    }

//    // MESSAGE<send>
//    @PostMapping("/messages/send")
//    public Message sendMessage(@RequestBody Message message) {
//        return adminService.sendMessage(message);
//    }

    // <receive>
    @GetMapping("/messages/incoming")
    public List<Message> getNewMessages(@RequestBody(required = false) Message message) {
        return adminService.incomingMessages(message);
    }

//
//    @PostMapping("/messages/send")
//    public Message sendMessage(@RequestParam String regNumber,
//                               @RequestParam String content) {
//        return messageService.sendMessage(regNumber, "ADMIN", content);
//    }

    // Get all messages
    @GetMapping("/messages")
    public List<Message> getAllMessages() {
        return messageService.getAllMessages();
    }

    // Mark message as read
//    @PutMapping("/messages/{id}/read")
//    public Message markAsRead(@PathVariable Long id) {
//        return messageService.markAsRead(id);
//    }
//    @PostMapping("/approve-report/{id}")
//    public String approveReport(@PathVariable long id) {
//        studentService.approveReport(id);
//        return "Report approved and status updated.";
//    }




}
