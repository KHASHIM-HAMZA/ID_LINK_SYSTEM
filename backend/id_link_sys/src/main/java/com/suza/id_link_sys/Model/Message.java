package com.suza.id_link_sys.Model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "message")
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Link to student (ID card owner)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reg_number", nullable = false)
    @JsonBackReference
    private Students student;

    private String senderName;
    private String senderEmail;
    private String content;
    private boolean readStatus = false;
    private LocalDateTime sentAt = LocalDateTime.now();

    private boolean is_read = false;


    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Students getStudent() { return student; }
    public void setStudent(Students student) { this.student = student; }

    public boolean isIs_read() {
        return is_read;
    }

    public void setIs_read(boolean is_read) {
        this.is_read = is_read;
    }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderEmail() { return senderEmail; }
    public void setSenderEmail(String senderEmail) { this.senderEmail = senderEmail; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public boolean isReadStatus() { return readStatus; }
    public void setReadStatus(boolean readStatus) { this.readStatus = readStatus; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public void setStudentRegNumber(String currentRegNumber) {
        this.student.setRegNumber(currentRegNumber);
    }
}
