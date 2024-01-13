package com.example.EssaieProject.model;

public class PostulationWithPublication {
    private Postulation postulation;
    private Publication publication;
    private User user;

    public PostulationWithPublication() {

    }

    public PostulationWithPublication(Postulation postulation, Publication publication, User user) {
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
