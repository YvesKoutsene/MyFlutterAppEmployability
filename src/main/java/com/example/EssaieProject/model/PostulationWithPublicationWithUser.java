package com.example.EssaieProject.model;
import com.example.EssaieProject.model.Publication;
import com.example.EssaieProject.model.User;

public class PostulationWithPublicationWithUser {
    private Postulation postulation;
    private Publication publication;
    private User user;

    public PostulationWithPublicationWithUser(Postulation postulation, Publication publication, User user) {
        this.postulation = postulation;
        this.publication = publication;
        this.user = user;
    }

    public Postulation getPostulation() {
        return postulation;
    }

    public void setPostulation(Postulation postulation) {
        this.postulation = postulation;
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
