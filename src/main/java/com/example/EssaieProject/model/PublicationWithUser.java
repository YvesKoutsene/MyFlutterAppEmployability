package com.example.EssaieProject.model;
import com.example.EssaieProject.model.Publication;
import com.example.EssaieProject.model.User;

public class PublicationWithUser {
    private Publication publication;
    private User user;

    public PublicationWithUser(Publication publication, User user) {
        this.publication = publication;
        this.user = user;
    }

    public PublicationWithUser(String message) {
    }

    public Publication getPublication() {
        return publication;
    }

    public User getUser() {
        return user;
    }
}
