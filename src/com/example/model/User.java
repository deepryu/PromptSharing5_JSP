package com.example.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String password;
    private String role;
    private String email;
    private String fullName;
    private boolean isActive;
    private Timestamp lastLogin;
    private int failedLoginAttempts;
    private Timestamp accountLockedUntil;
    private Timestamp createdAt;

    // Constructors
    public User() {}

    public User(String username, String password) {
        this.username = username;
        this.password = password;
        this.role = "USER";
        this.isActive = true;
        this.failedLoginAttempts = 0;
    }

    public User(String username, String password, String role) {
        this.username = username;
        this.password = password;
        this.role = role;
        this.isActive = true;
        this.failedLoginAttempts = 0;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public Timestamp getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }

    public int getFailedLoginAttempts() {
        return failedLoginAttempts;
    }

    public void setFailedLoginAttempts(int failedLoginAttempts) {
        this.failedLoginAttempts = failedLoginAttempts;
    }

    public Timestamp getAccountLockedUntil() {
        return accountLockedUntil;
    }

    public void setAccountLockedUntil(Timestamp accountLockedUntil) {
        this.accountLockedUntil = accountLockedUntil;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // 편의 메서드들
    public boolean hasRole(String roleName) {
        return this.role != null && this.role.equals(roleName);
    }

    public boolean hasAnyRole(String... roleNames) {
        if (this.role == null) return false;
        for (String roleName : roleNames) {
            if (this.role.equals(roleName)) {
                return true;
            }
        }
        return false;
    }

    public boolean isAdmin() {
        return hasAnyRole("ADMIN", "SUPER_ADMIN");
    }

    public boolean isSuperAdmin() {
        return hasRole("SUPER_ADMIN");
    }

    public boolean isInterviewer() {
        return hasAnyRole("INTERVIEWER", "ADMIN", "SUPER_ADMIN");
    }

    public boolean isAccountLocked() {
        return accountLockedUntil != null && 
               accountLockedUntil.after(new Timestamp(System.currentTimeMillis()));
    }

    public boolean isAccountNonLocked() {
        return !isAccountLocked();
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", role='" + role + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", isActive=" + isActive +
                ", failedLoginAttempts=" + failedLoginAttempts +
                ", isAccountLocked=" + isAccountLocked() +
                '}';
    }
} 