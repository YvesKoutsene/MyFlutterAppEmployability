package com.example.EssaieProject.model;

public class PublicationWithUserInfo {
    private Publication publication;
    private User user;

    public PublicationWithUserInfo(Publication publication, User user) {
        this.publication = publication;
        this.user = user;
    }

    public Publication getPublication() {
        return publication;
    }

    public void setPublication(Publication publication) {
        this.publication = publication;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

}
