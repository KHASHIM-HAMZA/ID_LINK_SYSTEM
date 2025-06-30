package com.suza.id_link_sys.Model;

import jakarta.persistence.*;


@Entity
@Table
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)

    private Long id;
    private String regNumber;
    private String Sender;
    private String content;
    private boolean isRead;


    public Message() {
    }


    public Message(boolean isRead, String content, String sender, String regNumber, Long id) {
        this.isRead = isRead;
        this.content = content;
        Sender = sender;
        this.regNumber = regNumber;
        this.id = id;
    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRegNumber() {
        return regNumber;
    }

    public void setRegNumber(String regNumber) {
        this.regNumber = regNumber;
    }

    public String getSender() {
        return Sender;
    }

    public void setSender(String sender) {
        Sender = sender;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        this.isRead = read;
    }

    @Override
    public String toString() {
        return "Message{" +
                "id=" + id +
                ", regNumber='" + regNumber + '\'' +
                ", Sender='" + Sender + '\'' +
                ", content='" + content + '\'' +
                ", read=" + isRead +
                '}';
    }
}
