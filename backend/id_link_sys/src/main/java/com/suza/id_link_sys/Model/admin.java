package com.suza.id_link_sys.Model;

public class admin {

    private String Username;
    private String Password;

    public admin(String username, String password) {
        Username = username;
        Password = password;
    }

    public admin() {}


    public String getUsername() {
        return Username;
    }

    public void setUsername(String username) {
        Username = username;
    }

    public String getPassword() {
        return Password;
    }

    public void setPassword(String password) {
        Password = password;
    }

    @Override
    public String toString() {
        return "admin{" +
                "Username='" + Username + '\'' +
                ", Password='" + Password + '\'' +
                '}';
    }
}

