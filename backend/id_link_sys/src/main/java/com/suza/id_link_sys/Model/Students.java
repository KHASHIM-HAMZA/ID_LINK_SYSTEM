package com.suza.id_link_sys.Model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "students")
public class Students {
    @Id
    private String regNumber;

    private String fullName;
    private String password = "2025";
    private int year;
    private String email;
    private int phoneNo;
    private String photoUrl;
    private String course;
    private int requestCount = 0; // Tracks number of ID requests

    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference // Allows serialization of the child (StudentIDRequest) collection
    private List<StudentIDRequest> idRequests = new ArrayList<>();

    // Constructor with required fields
    public Students(String regNumber, String fullName, String email, int phoneNo, String photoUrl, String course, int year) {
        this.regNumber = regNumber;
        this.fullName = fullName;
        this.email = email;
        this.phoneNo = phoneNo;
        this.photoUrl = photoUrl;
        this.course = course;
        this.year = year;
    }

    // Default constructor
    public Students() {
    }
    // Getters and Setters
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
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

    public int getRequestCount() {
        return requestCount;
    }

    public void setRequestCount(int requestCount) {
        this.requestCount = requestCount;
    }

    public List<StudentIDRequest> getIdRequests() {
        return idRequests;
    }

    public void setIdRequests(List<StudentIDRequest> idRequests) {
        this.idRequests = idRequests;
    }

    @Override
    public String toString() {
        return "Students{" +
                "regNumber='" + regNumber + '\'' +
                ", fullName='" + fullName + '\'' +
                ", password='" + password + '\'' +
                ", year=" + year +
                ", email='" + email + '\'' +
                ", phoneNo=" + phoneNo +
                ", photoUrl='" + photoUrl + '\'' +
                ", course='" + course + '\'' +
                ", requestCount=" + requestCount +
                ", idRequests=" + idRequests +
                '}';
    }
}

