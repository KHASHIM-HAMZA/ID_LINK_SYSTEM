package com.suza.id_link_sys.Model;

import jakarta.persistence.*;

import java.time.LocalDateTime;


@Entity
@Table
public class StudentIDRequest {
    @Id
    @SequenceGenerator(
            name = "idRequest_sequence",
            sequenceName = "idRequest_sequence",
            allocationSize = 1
    )
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "idRequest_sequence")

    private Long id;

    private String fullName;
    private String regNumber;
    private String course;
    private int yearOfStudy;
    private String photoUrl;
    private String email;
    private String qrCode;
    private LocalDateTime requestDate;
    private String status = "Pending"; // Pending, Approved, Rejected
    private boolean printed = false;
    private int requestCount = 0;
    private int phoneNo;


    public StudentIDRequest(Long id, String fullName, String regNumber, String course, int yearOfStudy, String photoUrl, String email, String qrCode, LocalDateTime requestDate, String status, boolean printed, int requestCount,  int phoneNo) {
        this.id = id;
        this.fullName = fullName;
        this.regNumber = regNumber;
        this.course = course;
        this.yearOfStudy = yearOfStudy;
        this.photoUrl = photoUrl;
        this.email = email;
        this.qrCode = qrCode;
        this.requestDate = requestDate;
        this.status = status;
        this.printed = printed;
        this.requestCount = requestCount;
        this.phoneNo = phoneNo;
    }

    public StudentIDRequest() {

    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getRegNumber() {
        return regNumber;
    }

    public void setRegNumber(String regNumber) {
        this.regNumber = regNumber;
    }

    public String getCourse() {
        return course;
    }

    public void setCourse(String course) {
        this.course = course;
    }

    public int getYearOfStudy() {
        return yearOfStudy;
    }

    public void setYearOfStudy(int yearOfStudy) {
        this.yearOfStudy = yearOfStudy;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public LocalDateTime getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(LocalDateTime requestDate) {
        this.requestDate = requestDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isPrinted() {
        return printed;
    }

    public void setPrinted(boolean printed) {
        this.printed = printed;
    }

    public int getRequestCount() {
        return requestCount;
    }

    public void setRequestCount(int requestCount) {
        this.requestCount = requestCount;
    }

    public int getPhoneNo() {
        return phoneNo;
    }

    public void setPhoneNo(int phoneNo) {
        this.phoneNo = phoneNo;
    }

    @Override
    public String toString() {
        return "StudentIDRequest{" +
                "id=" + id +
                ", fullName='" + fullName + '\'' +
                ", regNumber='" + regNumber + '\'' +
                ", course='" + course + '\'' +
                ", yearOfStudy=" + yearOfStudy +
                ", photoUrl='" + photoUrl + '\'' +
                ", email='" + email + '\'' +
                ", qrCode='" + qrCode + '\'' +
                ", requestDate=" + requestDate +
                ", status='" + status + '\'' +
                ", printed=" + printed +
                ", requestCount=" + requestCount +
                ", phoneNo=" + phoneNo +
                '}';
    }
}
