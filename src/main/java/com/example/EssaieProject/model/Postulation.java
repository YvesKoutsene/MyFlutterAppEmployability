package com.example.EssaieProject.model;
import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import java.util.Arrays;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.apache.tomcat.util.codec.binary.Base64;

import java.util.Arrays;

@Entity
@Table(name = "postulations")
public class Postulation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String datePostulation;
    private String statut;

    @Lob
    @Column(length = 10485760)
    private byte[] cvFile;

    @Lob
    @Column(length = 10485760)
    private byte[] lettreMotivationFile;

    //jointure
    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonBackReference
    private User user;

    //Jointure pour la classe publication
    @ManyToOne
    @JoinColumn(name = "publication_id")
    private Publication publication;

    public Publication getPublication() {
        return publication;
    }

    public void setPublication(Publication publication) {
        this.publication = publication;
    }

    public Postulation() {
    }

    public Postulation( String datePostulation, String statut, byte[] cvFile, byte[] lettreMotivationFile, User user, Publication publication) {
        this.datePostulation = datePostulation;
        this.statut = statut;
        this.cvFile = cvFile;
        this.lettreMotivationFile = lettreMotivationFile;
        this.user = user;
        this.publication = publication;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDatePostulation() {
        return datePostulation;
    }

    public void setDatePostulation(String datePostulation) {
        this.datePostulation = datePostulation;
    }

    public byte[] getCvFile() {
        return cvFile;
    }

    public void setCvFile(byte[] cvFile) {
        this.cvFile = cvFile;
    }

    public byte[] getLettreMotivationFile() {
        return lettreMotivationFile;
    }

    public void setLettreMotivationFile(byte[] lettreMotivationFile) {
        this.lettreMotivationFile = lettreMotivationFile;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    @Override
    public String toString() {
        return "Postulation{" +
                ", datePostulation='" + datePostulation + '\'' +
                ", statut='" + statut + '\'' +
                ", cvFile=" + Arrays.toString(cvFile) +
                ", lettreMotivationFile=" + Arrays.toString(lettreMotivationFile) +
                ", user=" + user +
                ", publication=" + publication +
                '}';
    }

    public String getCvFileBase64() {
        return Base64.encodeBase64String(cvFile);
    }

    public String getLettreMotivationFileBase64() {
        return Base64.encodeBase64String(lettreMotivationFile);
    }

}
