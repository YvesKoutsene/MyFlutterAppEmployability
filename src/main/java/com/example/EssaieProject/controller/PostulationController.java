package com.example.EssaieProject.controller;

import com.example.EssaieProject.model.*;
import com.example.EssaieProject.repository.PostulationRepository;
import com.example.EssaieProject.repository.UserRepository;
import com.example.EssaieProject.service.PostulationService;
import com.example.EssaieProject.service.PublicationService;
import com.example.EssaieProject.service.UserService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/postulations")
public class PostulationController {
    private final PostulationService postulationService;
    private  final PublicationService publicationService;
    private final UserService userService;
    private final UserRepository userRepository;
    private final PostulationRepository postulationRepository;

    @Autowired
    public PostulationController(PostulationService postulationService, PublicationService publicationService, UserService userService,UserRepository userRepository,PostulationRepository postulationRepository) {
        this.postulationService = postulationService;
        this.publicationService = publicationService;
        this.userService = userService;
        this.userRepository = userRepository;
        this.postulationRepository = postulationRepository;
    }

    @PostMapping("/{userId}")
    public Postulation savePostulation(@PathVariable Long userId, @RequestBody Postulation postulation) {
        User user = userService.getUserById(userId);
        postulation.setUser(user);
        return postulationService.savePostulation(postulation);
    }

    //Afficher les postulations des offres
    @GetMapping("/employer/{employerId}/all-postulations")
    public List<PostulationWithPublicationWithUser> getAllPostulationsForEmployer(@PathVariable Long employerId) {
        return postulationService.getAllPostulationsForEmployer(employerId);
    }

    //Valider une postulation
    @PutMapping("/{postulationId}/valider")
    public ResponseEntity<?> validerStatut(@PathVariable Long postulationId) {
        postulationService.validerStatut(postulationId);
        return ResponseEntity.ok("Statut validé avec succès.");
    }

    @PutMapping("/{postulationId}/rejeter")
    public ResponseEntity<?> rejeterStatut(@PathVariable Long postulationId) {
        postulationService.rejeterStatut(postulationId);
        return ResponseEntity.ok("Statut rejeté avec succès.");
    }

    //Afficher les postulations ayant un statut accepter ou rejeter d'un user
    @GetMapping("/user/{userId}/accepted-or-rejected")
    public ResponseEntity<List<Postulation>> getAcceptedOrRejectedPostulationsByUserId(@PathVariable Long userId) {
        List<Postulation> postulations = postulationService.getPostulationsByUserIdAndAcceptedOrRejected(userId);
        return ResponseEntity.ok(postulations);
    }

    //New 777
    @GetMapping("/users/{userId}/postulations")
    public ResponseEntity<List<PostulationWithPublication>> getUserPostulationsWithStatuts(
            @PathVariable Long userId) {
        List<PostulationWithPublication> postulations = postulationService.getPostulationsWithPublications(userId);
        return ResponseEntity.ok(postulations);
    }


    //Supprimer une postulation
    @DeleteMapping("/{id}/delete")
    public ResponseEntity<String> deletePostulation(@PathVariable("id") Long postulationId) {
        try {
            postulationService.deletePostulation(postulationId);
            return ResponseEntity.ok("Postulation supprimée avec succès.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Publication non trouvée avec cet id: " + postulationId);
        }
    }

    //Pour télécharger Cv et lettre de motivation
    @GetMapping("/{id}/cv")
    public ResponseEntity<ByteArrayResource> downloadCvFile(@PathVariable Long id) {
        Optional<Postulation> postulationOptional = postulationService.getPostulationById(id);
        if (postulationOptional.isPresent()) {
            Postulation postulation = postulationOptional.get();
            byte[] cvFile = postulation.getCvFile();
            if (cvFile != null) {
                ByteArrayResource resource = new ByteArrayResource(cvFile);
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=cvFile.pdf")
                        .body(resource);
            }
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/{id}/lettre-motivation")
    public ResponseEntity<ByteArrayResource> downloadLettreMotivationFile(@PathVariable Long id) {
        Optional<Postulation> postulationOptional = postulationService.getPostulationById(id);
        if (postulationOptional.isPresent()) {
            Postulation postulation = postulationOptional.get();
            byte[] lettreMotivationFile = postulation.getLettreMotivationFile();
            if (lettreMotivationFile != null) {
                ByteArrayResource resource = new ByteArrayResource(lettreMotivationFile);
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=lettreMotivationFile.pdf")
                        .body(resource);
            }
        }
        return ResponseEntity.notFound().build();
    }

    //New 777
    @GetMapping("/publication/{publicationId}")
    public ResponseEntity<List<PostulationWithUser>> getPostulationsWithUsersByPublicationId(@PathVariable Long publicationId) {
        List<PostulationWithUser> postulationsWithUsers = postulationService.getPostulationsWithUsersByPublicationId(publicationId);
        return ResponseEntity.ok(postulationsWithUsers);
    }

}
