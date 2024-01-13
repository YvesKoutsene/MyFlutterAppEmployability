package com.example.EssaieProject.model;

public class PostulationWithUser {
    private Postulation postulation;
    private User user;

    public PostulationWithUser(Postulation postulation, User user) {
        this.postulation = postulation;
        this.user = user;
    }

    public Postulation getPostulation() {
        return postulation;
    }

    public void setPostulation(Postulation postulation) {
        this.postulation = postulation;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
