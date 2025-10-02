package com.suza.id_link_sys.Service;


import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.MessageRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MessageService {
    private final MessageRepository messageRepository;
    private final StudentsRepository studentRepository;

    public MessageService(MessageRepository messageRepository, StudentsRepository studentRepository) {
        this.messageRepository = messageRepository;
        this.studentRepository = studentRepository;
    }


    public Message sendMessage(String regNo, String senderName, String senderEmail, String content) {
        Students student = studentRepository.findById(regNo)
                .orElseThrow(() -> new RuntimeException("Student not found with regNo: " + regNo));

        Message msg = new Message();
        msg.setStudent(student);
        msg.setSenderName(senderName);
        msg.setSenderEmail(senderEmail);
        msg.setContent(content);

        return messageRepository.save(msg);
    }


    // Get messages for a student
//    public List<Message> getMessagesByRegNumber(String regNumber) {
//        return messageRepository.findByRegNumber(regNumber);
//    }


    // Get all messages (for Admin)
    public List<Message> getAllMessages() {
        return messageRepository.findAll();
    }




    public List<Message> getMessagesForStudent(String regNumber) {
        Students student = studentRepository.findByRegNumber(regNumber)
                .orElseThrow(() -> new RuntimeException("Student not found with regNo: " + regNumber));
        return messageRepository.findByStudent(student);
    }
}
