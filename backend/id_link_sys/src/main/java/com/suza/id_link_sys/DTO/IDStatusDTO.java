package com.suza.id_link_sys.DTO;


import java.time.LocalDateTime;

public class IDStatusDTO {
    private String status;
    private LocalDateTime requestDate;
    private LocalDateTime completionDate;
    private StudentDetailsDTO studentDetails;

    // Constructors
    public IDStatusDTO() {}

    public IDStatusDTO(String status, LocalDateTime requestDate,
                       LocalDateTime completionDate, StudentDetailsDTO studentDetails) {
        this.status = status;
        this.requestDate = requestDate;
        this.completionDate = completionDate;
        this.studentDetails = studentDetails;
    }

    // Getters and Setters
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(LocalDateTime requestDate) {
        this.requestDate = requestDate;
    }

    public LocalDateTime getCompletionDate() {
        return completionDate;
    }

    public void setCompletionDate(LocalDateTime completionDate) {
        this.completionDate = completionDate;
    }

    public StudentDetailsDTO getStudentDetails() {
        return studentDetails;
    }

    public void setStudentDetails(StudentDetailsDTO studentDetails) {
        this.studentDetails = studentDetails;
    }

    // Inner DTO class for student details
    public static class StudentDetailsDTO {
        private String fullName;
        private String course;
        private Integer yearOfStudy;
        private String photoUrl;

        // Constructors
        public StudentDetailsDTO() {}

        public StudentDetailsDTO(String fullName, String course,
                                 Integer yearOfStudy, String photoUrl) {
            this.fullName = fullName;
            this.course = course;
            this.yearOfStudy = yearOfStudy;
            this.photoUrl = photoUrl;
        }

        // Getters and Setters
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

        public String getPhotoUrl() {
            return photoUrl;
        }

        public void setPhotoUrl(String photoUrl) {
            this.photoUrl = photoUrl;
        }
    }
}