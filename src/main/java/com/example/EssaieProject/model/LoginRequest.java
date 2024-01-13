package com.example.EssaieProject.model;

public class LoginRequest {

    private String email;
    private String password;
    private boolean isactivate;

    public boolean isIsactivate() {
        return isactivate;
    }

    public void setIsactivate(boolean isactivate) {
        this.isactivate = isactivate;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
