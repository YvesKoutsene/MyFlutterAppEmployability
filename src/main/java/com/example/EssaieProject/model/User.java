package com.example.EssaieProject.model;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;
import org.springframework.stereotype.Service;
import java.util.List;

@Data
@Entity
@Table(name = "user")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private String password;
    private String confpassword;
    private String profile;
    private boolean isactivate;

    @Column(name = "verification_code")
    private String verificationCode;

    //Jointure
    //@JsonManagedReference
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Postulation> postulations;

    //Jointure
    //@JsonIgnore
    @OneToMany(mappedBy = "user2", cascade = CascadeType.ALL)
    private List<Publication> publications;

    //Jointure
    @OneToMany(mappedBy = "user3", cascade = CascadeType.ALL)
    private List<Demande> demandes;

    public List<Demande> getDemandes() {
        return demandes;
    }

    public void setDemandes(List<Demande> demandes) {
        this.demandes = demandes;
    }

    public String getVerificationCode() {
        return verificationCode;
    }

    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }

    public boolean isIsactivate() {
        return isactivate;
    }

    public void setIsactivate(boolean isactivate) {
        this.isactivate = isactivate;
    }

    public List<Postulation> getPostulations() {
        return postulations;
    }
    public void setPostulations(List<Postulation> postulations) {
        this.postulations = postulations;
    }

    public List<Publication> getPublications() {
        return publications;
    }
    public void setPublications(List<Publication> publications) {
        this.publications = publications;
    }

    public User() {
    }

    public User(String firstName, String lastName, String email, String phoneNumber, String password, String confpassword, String profile, boolean isactivate, List<Postulation> postulations, List<Publication> publications, List<Demande> demandes) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.password = password;
        this.confpassword = confpassword;
        this.profile = profile;
        this.isactivate = isactivate;
        this.postulations = postulations;
        this.publications = publications;
        this.demandes = demandes;
    }

    // Getters and setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getConfpassword() {
        return confpassword;
    }

    public void setConfpassword(String confpassword) {
        this.confpassword = confpassword;
    }

    public String getProfile() {
        return profile;
    }

    public void setProfile(String profile) {
        this.profile = profile;
    }

    @Override
    public String toString() {
        return "User{" +
                "firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", email='" + email + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", password='" + password + '\'' +
                ", confpassword='" + confpassword + '\'' +
                ", profile='" + profile + '\'' +
                ", postulations=" + postulations +
                '}';
    }
}