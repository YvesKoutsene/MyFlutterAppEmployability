package com.example.EssaieProject.controller;

import com.example.EssaieProject.model.Demande;
import com.example.EssaieProject.model.User;
import com.example.EssaieProject.service.DemandeService;
import com.example.EssaieProject.service.EmailService;
import com.example.EssaieProject.service.UserService;
import jakarta.activation.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.Base64;
import java.util.List;

import jakarta.activation.DataHandler;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;

import javax.mail.MessagingException;
import javax.mail.util.ByteArrayDataSource;


@RestController
@RequestMapping("/demandes")
public class DemandeController {

    private final DemandeService demandeService;
    private final UserService userService;
    private final EmailService emailService;

    @Autowired
    public DemandeController(DemandeService demandeService, UserService userService, EmailService emailService) {
        this.demandeService = demandeService;
        this.userService = userService;
        this.emailService = emailService;
    }

    // Faire une demande par un user
    /*@PostMapping("/user/{userId}")
    public Demande createDemande(@PathVariable Long userId, @RequestBody Demande demande){
        User user = userService.getUserById(userId);
        demande.setUser3(user);
        return demandeService.createDemande(demande);
    }*/

    @PostMapping("/user/{userId}")
    public Demande createDemande(@PathVariable Long userId, @RequestBody Demande demande) throws MessagingException {
        User user = userService.getUserById(userId);
        demande.setUser3(user);
        Demande createdDemande = demandeService.createDemande(demande);

        // Envoyer un e-mail aux administrateurs avec les détails de la demande
        sendEmailToAdmins(createdDemande);

        return createdDemande;
    }

    private void sendEmailToAdmins(Demande demande) throws MessagingException {
        List<String> adminEmails = userService.getAdminEmails(); // Obtenir les adresses e-mail des administrateurs

        String subject = "Demande";
        String content = "Une nouvelle demande a été créée avec les détails suivants:\n\n"
                + "Date de la demande: " + demande.getDateDemande() + "\n"
                + "Type de demande: " + demande.getTypeDemande() + "\n"
                + "Domaine: " + demande.getDomaine() + "\n"
                + "Region: " + demande.getRegion() + "\n"
                + "Présentation: " + demande.getPresentation() + "\n"
                +"Ci-joint document";

        byte[] cvFile = demande.getCvFile2();

        for (String adminEmail : adminEmails) {
            if (cvFile != null) {
                // Envoyer l'e-mail avec la pièce jointe du fichier CV
                emailService.sendEmailWithAttachmentAndText(adminEmail, subject, content, cvFile, "fichierCV.pdf");
            } else {
                // Envoyer l'e-mail sans pièce jointe du fichier CV
                emailService.sendVerificationEmail(adminEmail, subject, content);
            }
        }
    }

    // Afficher les demandes par région
    @GetMapping("/region/{region}")
    public List<Demande> getDemandesByRegion(@PathVariable String region) {
        return demandeService.getDemandesByRegion(region);
    }

    // Afficher les demandes par utilisateur
    @GetMapping("/user/{userId}/user")
    public List<Demande> getDemandesByUserId(@PathVariable Long userId) {
        return demandeService.getDemandesByUserId(userId);
    }

    //Supprimer une demande
    @DeleteMapping("/{id}/delete")
    public ResponseEntity<String> deleteDemande(@PathVariable("id") Long demandeId) {
        try {
            demandeService.deleteDemande(demandeId);
            return ResponseEntity.ok("Demande supprimée avec succès.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Demande non trouvée avec ce id: " + demandeId);
        }
    }

}
