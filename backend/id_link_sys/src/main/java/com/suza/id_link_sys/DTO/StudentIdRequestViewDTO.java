// StudentIdRequestViewDTO.java
package com.suza.id_link_sys.DTO;

import com.suza.id_link_sys.Model.StudentIDRequest;
import java.nio.file.Paths;

public class StudentIdRequestViewDTO {
    private Long id;
    private String regNumber;
    private String fullName;
    private String course;
    private Integer yearOfStudy;
    private String status;
    private Boolean printed;
    private String photoUrl; // 👈 what Flutter uses
    private String reportUrl;
    private String email;
    private Integer phoneNo;

    // getters/setters


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

    public Integer getYearOfStudy() {
        return yearOfStudy;
    }

    public void setYearOfStudy(Integer yearOfStudy) {
        this.yearOfStudy = yearOfStudy;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getPrinted() {
        return printed;
    }

    public void setPrinted(Boolean printed) {
        this.printed = printed;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Integer getPhoneNo() {
        return phoneNo;
    }

    public void setPhoneNo(Integer phoneNo) {
        this.phoneNo = phoneNo;
    }

    public static StudentIdRequestViewDTO fromEntity(StudentIDRequest e, String baseUrl) {
        StudentIdRequestViewDTO dto = new StudentIdRequestViewDTO();
        dto.setId(e.getId());
        dto.setRegNumber(e.getStudent().getRegNumber());
        dto.setFullName(e.getFullName());
        dto.setCourse(e.getCourse());
        dto.setYearOfStudy(e.getYearOfStudy());
        dto.setStatus(e.getStatus());
        dto.setPrinted(e.isPrinted());
        dto.setReportUrl(e.getReportUrl());
        dto.setEmail(e.getEmail());
        dto.setPhoneNo(e.getPhoneNo());

        // 🔁 Convert absolute path -> public URL for /uploads/**
        if (e.getPhotoPath() != null) {
            String filename = Paths.get(e.getPhotoPath().trim()).getFileName().toString();
            // baseUrl = http://localhost:8080 (built in controller at request time)
            dto.setPhotoUrl(baseUrl + "/uploads/request_photos/" + filename);
        }

        return dto;
    }
}
