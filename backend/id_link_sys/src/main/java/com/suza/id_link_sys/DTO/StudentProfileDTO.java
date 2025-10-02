package com.suza.id_link_sys.DTO;

public class StudentProfileDTO {
    private String password;

    private String email;
    private int phoneNo;
    private String photoUrl;
    private String course;
    private String idRequests;

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getPhoneNo() {
        return phoneNo;
    }

    public void setPhoneNo(int phoneNo) {
        this.phoneNo = phoneNo;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getCourse() {
        return course;
    }

    public void setCourse(String course) {
        this.course = course;
    }

    public String getIdRequests() {
        return idRequests;
    }

    public void setIdRequests(String idRequests) {
        this.idRequests = idRequests;
    }
}
