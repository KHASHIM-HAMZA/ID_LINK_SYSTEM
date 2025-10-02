package com.suza.id_link_sys.Model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "studentidrequest")
public class StudentIDRequest {
    @Id
    @SequenceGenerator(
            name = "idRequest_sequence",
            sequenceName = "idRequest_sequence",
            allocationSize = 1
    )
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "idRequest_sequence")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "reg_number", nullable = false)
    @JsonBackReference
    private Students student;

    private String qrCode;
    private LocalDateTime requestDate;
    private String status = "Pending";
    private boolean printed = false;
    private Integer yearOfStudy;
    private Integer requestCount = 0;
    private Integer phoneNo;
    private String fullName;
    private String course;
    private String email;
    private String photoUrl;
    private String reportUrl;
    private String photoPath;


    public StudentIDRequest(Long id, Students student, String qrCode, LocalDateTime requestDate, String status, boolean printed, Integer yearOfStudy, Integer requestCount, Integer phoneNo, String fullName, String course, String email, String photoUrl, String reportUrl, String photoPath) {
        this.id = id;
        this.student = student;
        this.qrCode = qrCode;
        this.requestDate = requestDate;
        this.status = status;
        this.printed = printed;
        this.yearOfStudy = yearOfStudy;
        this.requestCount = requestCount;
        this.phoneNo = phoneNo;
        this.fullName = fullName;
        this.course = course;
        this.email = email;
        this.photoUrl = photoUrl;
        this.reportUrl = reportUrl;
        this.photoPath = photoPath;
    }

    public StudentIDRequest() {
    }

    public Long getId() {
        return id;
    }

    public String getPhotoPath() {
        return photoPath;
    }

    public void setPhotoPath(String photoPath) {
        this.photoPath = photoPath;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Students getStudent() {
        return student;
    }

    public void setStudent(Students student) {
        this.student = student;
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

    public Integer getYearOfStudy() {
        return yearOfStudy;
    }

    public void setYearOfStudy(Integer yearOfStudy) {
        this.yearOfStudy = yearOfStudy;
    }

    public Integer getRequestCount() {
        return requestCount;
    }

    public void setRequestCount(Integer requestCount) {
        this.requestCount = requestCount;
    }

    public Integer getPhoneNo() {
        return phoneNo;
    }

    public void setPhoneNo(Integer phoneNo) {
        this.phoneNo = phoneNo;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getCourse() {
        return course;
    }

    public void setCourse(String course) {
        this.course = course;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getReportUrl() {
        return reportUrl;
    }

    public void setReportUrl(String reportUrl) {
        this.reportUrl = reportUrl;
    }

    @Override
    public String toString() {
        return "StudentIDRequest{" +
                "id=" + id +
                ", student=" + student +
                ", qrCode='" + qrCode + '\'' +
                ", requestDate=" + requestDate +
                ", status='" + status + '\'' +
                ", printed=" + printed +
                ", yearOfStudy=" + yearOfStudy +
                ", requestCount=" + requestCount +
                ", phoneNo=" + phoneNo +
                ", reportUrl='" + reportUrl + '\'' +
                '}';
    }

    public String getRegNumber() {
        return student.getRegNumber();
    }
}
