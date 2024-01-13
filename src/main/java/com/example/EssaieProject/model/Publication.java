package com.example.EssaieProject.model;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "publications")
public class Publication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String titre;
    private String dateOffre;
    private String dateExpiration;
    private String typeOffre;
    private String statut;
    private String competences;
    private String region;
    private String description;

    //Jointure
    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user2;

    // Jointure pour les postulations
    @JsonIgnore
    @OneToMany(mappedBy = "publication", cascade = CascadeType.ALL)
    private List<Postulation> postulations;

    public List<Postulation> getPostulations() {
        return postulations;
    }
    public void setPostulations(List<Postulation> postulations) {
        this.postulations = postulations;
    }

    public Publication() {
    }

    public Publication(String titre, String dateOffre, String dateExpiration, String typeOffre, String statut, String competences, String region, String description, User user2, List<Postulation> postulations) {
        this.titre = titre;
        this.dateOffre = dateOffre;
        this.dateExpiration = dateExpiration;
        this.typeOffre = typeOffre;
        this.statut = statut;
        this.competences = competences;
        this.region = region;
        this.description = description;
        this.user2 = user2;
        this.postulations = postulations;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitre() {
        return titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public String getDateOffre() {
        return dateOffre;
    }

    public void setDateOffre(String dateOffre) {
        this.dateOffre = dateOffre;
    }

    public String getTypeOffre() {
        return typeOffre;
    }

    public void setTypeOffre(String typeOffre) {
        this.typeOffre = typeOffre;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getCompetences() {
        return competences;
    }

    public void setCompetences(String competences) {
        this.competences = competences;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public User getUser2() {
        return user2;
    }

    public void setUser2(User user2) {
        this.user2 = user2;
    }

    public String getDateExpiration() {
        return dateExpiration;
    }

    public void setDateExpiration(String dateExpiration) {
        this.dateExpiration = dateExpiration;
    }

    @Override
    public String toString() {
        return "Publication{" +
                "titre='" + titre + '\'' +
                ", dateOffre='" + dateOffre + '\'' +
                ", dateExpiration='" + dateExpiration + '\'' +
                ", typeOffre='" + typeOffre + '\'' +
                ", statut='" + statut + '\'' +
                ", competences='" + competences + '\'' +
                ", region='" + region + '\'' +
                ", description='" + description + '\'' +
                ", user2=" + user2 +
                ", postulations=" + postulations +
                '}';
    }
}
