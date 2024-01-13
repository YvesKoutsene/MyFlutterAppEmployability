package com.example.EssaieProject.exception;

public class EmailConnectionException extends RuntimeException {
    public EmailConnectionException(String message, Throwable cause) {
        super(message, cause);
    }
}
