package com.example.EssaieProject.exception;

public class EmailNotFoundException extends RuntimeException {
    public EmailNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
