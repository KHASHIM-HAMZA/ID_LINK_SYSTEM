package com.suza.id_link_sys.Service;

import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.MessageRepository;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AdminService {
    @Autowired
    StudentIDRequestRepository requestRepo;

    StudentsRepository studentRepo;

    @Autowired
    MessageRepository msgRepository;

    public List<StudentIDRequest> getPendingRequests() {
        List<StudentIDRequest> requests = requestRepo.findByStatus("Pending");
        return requestRepo.findAll();
    }

    @Transactional
    public void deletePendingRequests(String regNumber) {
        List<StudentIDRequest> requests = requestRepo.findByStudentRegNumber(regNumber);
        if (requests.isEmpty()) {
            throw new RuntimeException("No pending requests found for: " + regNumber);
        }
        requestRepo.deleteAll(requests);
    }

    @Transactional
    public StudentIDRequest updateStatus(String regNumber, String status) {
        StudentIDRequest req = requestRepo.findByStudentRegNumber(regNumber)
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Request not found: " + regNumber));
        req.setStatus(status);
        try {
            if (status.equals("Approved")) {
                PDFService.generateStudentIDCard(req);
                req.setPrinted(false);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error during approve process: " + e.getMessage());
        }
        return requestRepo.save(req);
    }

    @Transactional
    public StudentIDRequest approveRequest(String regNumber) {
        StudentIDRequest req = requestRepo.findByStudentRegNumber(regNumber)
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Request not found: " + regNumber));
        req.setStatus("Approved");
        return requestRepo.save(req);
    }

    public Message sendMessage(Message msg) {
        return msgRepository.save(msg);
    }

    public List<Message> incomingMessages(Message msg) {
        return msgRepository.findAll();
    }

    @Transactional
    public StudentIDRequest rejectRequest(String regNumber) {
        StudentIDRequest req = requestRepo.findByStudentRegNumber(regNumber)
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Request not found: " + regNumber));
        req.setStatus("Rejected");
        return requestRepo.save(req);
    }

    public List<StudentIDRequest> getApprovedIds() {
        return requestRepo.findByStatus("Approved");
    }
}