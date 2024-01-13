package com.example.EssaieProject.model;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.Arrays;

@Entity
@Table(name = "demandes")
public class Demande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String typeDemande;
    private String domaine;
    private String region;
    private String dateDemande;
    private String statut;
    @Lob
    @Column(length = 10485760) // Taille maximale du fichier : 10 Mo
    private byte[] cvFile2;

    private String presentation;

    public String getPresentation() {
        return presentation;
    }

    public void setPresentation(String presentation) {
        this.presentation = presentation;
    }

    @ManyToOne
    @JoinColumn(name = "userid")
    @JsonIgnore
    private User user3;

    public Demande() {
    }

    public Demande(String typeDemande, String domaine, String region, String dateDemande, String statut, byte[] cvFile2, String presentation, User user3) {
        this.typeDemande = typeDemande;
        this.domaine = domaine;
        this.region = region;
        this.dateDemande = dateDemande;
        this.statut = statut;
        this.cvFile2 = cvFile2;
        this.presentation = presentation;
        this.user3 = user3;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }



    public String getTypeDemande() {
        return typeDemande;
    }

    public void setTypeDemande(String typeDemande) {
        this.typeDemande = typeDemande;
    }

    public String getDomaine() {
        return domaine;
    }

    public void setDomaine(String domaine) {
        this.domaine = domaine;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getDateDemande() {
        return dateDemande;
    }

    public void setDateDemande(String dateDemande) {
        this.dateDemande = dateDemande;
    }

    public byte[] getCvFile2() {
        return cvFile2;
    }

    public void setCvFile2(byte[] cvFile2) {
        this.cvFile2 = cvFile2;
    }

    public User getUser3() {
        return user3;
    }

    public void setUser3(User user3) {
        this.user3 = user3;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    @Override
    public String toString() {
        return "Demande{" +
                "typeDemande='" + typeDemande + '\'' +
                ", domaine='" + domaine + '\'' +
                ", region='" + region + '\'' +
                ", dateDemande='" + dateDemande + '\'' +
                ", statut='" + statut + '\'' +
                ", cvFile2=" + Arrays.toString(cvFile2) +
                ", presentation='" + presentation + '\'' +
                ", user3=" + user3 +
                '}';
    }
}
