package com.suza.id_link_sys.Controller;

import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Service.MessageService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/messages")
public class MessageController {
    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    // Send message to student
    @PostMapping("/send")
    public ResponseEntity<Message> sendMessage(
            @RequestParam String regNumber,
            @RequestBody Map<String, String> body
    ) {
        Message msg = messageService.sendMessage(
                regNumber,
                body.get("senderName"),
                body.get("senderEmail"),
                body.get("content")
        );
        return ResponseEntity.ok(msg);
    }

    // Get all messages for student
    @GetMapping()
    public ResponseEntity<List<Message>> getMessages(@RequestParam String regNumber) {
        return ResponseEntity.ok(messageService.getMessagesForStudent(regNumber));
    }
}
