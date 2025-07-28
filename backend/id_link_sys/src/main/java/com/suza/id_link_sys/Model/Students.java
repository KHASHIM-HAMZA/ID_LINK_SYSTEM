package com.suza.id_link_sys.Model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class Students {
    @Id
    private String regNumber;
    private String fullName;
    private String password;

    private String email;
    private int phoneNo;
    private String photoUrl;


    public Students(String regNumber, String fullName, String password, String email, int phoneNo, String photoUrl) {
        this.regNumber = regNumber;
        this.fullName = fullName;
        this.password = password;
        this.email = email;
        this.phoneNo = phoneNo;
        this.photoUrl = photoUrl;
    }

    public Students() {
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

    @Override
    public String toString() {
        return "Students{" +
                "regNumber='" + regNumber + '\'' +
                ", fullName='" + fullName + '\'' +
                ", password='" + password + '\'' +
                ", email='" + email + '\'' +
                ", phoneNo=" + phoneNo +
                ", photoUrl='" + photoUrl + '\'' +
                '}';
    }
}
