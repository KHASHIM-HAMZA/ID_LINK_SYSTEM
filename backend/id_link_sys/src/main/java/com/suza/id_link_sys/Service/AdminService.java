package com.suza.id_link_sys.Service;


import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.MessageRepository;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Service
public class AdminService {
    @Autowired
    StudentIDRequestRepository requestRepo;

    @Autowired
    MessageRepository msgRepository;

    public List<StudentIDRequest> getPendingRequests() {
        return requestRepo.findAll();
    }



    @Transactional
    public void deletePendingRequests(@RequestParam String regNumber) {
        requestRepo.deleteByRegNumber(regNumber);
    }

    @Transactional
    public StudentIDRequest updateStatus(String regNumber, String status) {
        StudentIDRequest req = requestRepo.findByRegNumber(regNumber).orElseThrow();
        req.setStatus(status);

        try {
            PDFService.generateStudentIDCard(req);
            req.setPrinted(false); // Printed will be marked true by Bash script after printing
        } catch (Exception e) {
            throw new RuntimeException("Error during approve process: " + e.getMessage());
        }
        return requestRepo.save(req);
    }
    //APPROVED
    @Transactional
    public StudentIDRequest approveRequest(String regNumber) {
        StudentIDRequest req = requestRepo.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        req.setStatus("Approved");

        return requestRepo.save(req);
    }


    //MESSAGES<SEND>
    public Message sendMessage(Message msg) {
        return msgRepository.save(msg);
    }

    //<RECEIVE>
    public List<Message> incomingMessages(Message msg) {
        return msgRepository.findAll();
    }

    public StudentIDRequest rejectRequest(String regNumber) {
        StudentIDRequest req = requestRepo.findByRegNumber(regNumber).orElseThrow();
        req.setStatus("Rejected");
        return requestRepo.save(req);

    }

    public List<StudentIDRequest> getApprovedIds() {
        return requestRepo.findByStatus("Approved");
    }
}
