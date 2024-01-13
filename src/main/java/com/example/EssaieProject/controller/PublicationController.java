package com.example.EssaieProject.controller;
import com.example.EssaieProject.model.*;
import com.example.EssaieProject.repository.PublicationRepository;
import com.example.EssaieProject.service.PublicationService;
import com.example.EssaieProject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/publications")
public class PublicationController {
    private final PublicationService publicationService;
    private final UserService userService;
    private final PublicationRepository publicationRepository;

    @Autowired
    public PublicationController(PublicationService publicationService, UserService userService,PublicationRepository publicationRepository){
        this.publicationService = publicationService;
        this.userService = userService;
        this.publicationRepository = publicationRepository;
    }

    //Publier une offre par un user
    @PostMapping("/{userId}")
    public Publication savePublication(@PathVariable Long userId, @RequestBody Publication publication ){
        User user = userService.getUserById(userId);
        publication.setUser2(user);
        return publicationService.savePublication(publication);
    }

    @GetMapping("/accepted-publications")
    public List<PublicationWithUser> getAllAcceptedPublicationsWithUser() {
        List<Publication> acceptedPublications = publicationRepository.findByStatut("Accepter");
        List<PublicationWithUser> publicationsWithUsers = new ArrayList<>();

        LocalDate currentDate = LocalDate.now();

        for (Publication publication : acceptedPublications) {
            LocalDate expirationDate = LocalDate.parse(publication.getDateExpiration(), DateTimeFormatter.ofPattern("dd/M/yyyy"));

            if (!expirationDate.isBefore(currentDate) || expirationDate.isEqual(currentDate)) {
                User user = publication.getUser2();

                PublicationWithUser publicationWithUser = new PublicationWithUser(publication, user);
                publicationsWithUsers.add(publicationWithUser);
            }
        }

        // Tri des publicationsWithUsers du dernier au premier
        publicationsWithUsers.sort((a, b) -> b.getPublication().getDateOffre().compareTo(a.getPublication().getDateOffre()));

        return publicationsWithUsers;
    }

    //Afficher les publications sans statut("Attente")
    @GetMapping("/Attente")
    public List<PublicationWithUserInfo> getPublicationsInAttente() {
        List<Publication> publications = publicationService.getPublicationsWithStatus("Attente");

        List<PublicationWithUserInfo> result = new ArrayList<>();
        for (Publication publication : publications) {
            User user = publication.getUser2();
            PublicationWithUserInfo publicationWithUserInfo = new PublicationWithUserInfo(publication, user);
            result.add(publicationWithUserInfo);
        }

        return result;
    }

    //Postuler à une offre
    @PostMapping("/users/{userId2}/publications/{publicationId2}/postulations")
    public Postulation postuler(@PathVariable Long userId2, @PathVariable Long publicationId2, @RequestBody Postulation postulation) {
        return publicationService.postuler(userId2, publicationId2, postulation);
    }

    //Validation des publications
    @GetMapping("/{id}")
    public Publication getPublicationById(@PathVariable Long id) {
        return publicationService.getPublicationById(id);
    }
    //Accepter une publication
    @PutMapping("/{id}/validate")
    public void validatePublication(@PathVariable Long id) {
        publicationService.validatePublication(id);
    }
    //Rejeter une publication
    @PutMapping("/{id}/reject")
    public void rejectPublication(@PathVariable Long id) {
        publicationService.rejectPublication(id);
    }

    //Afficher les publications acceptées ou rejetées d'un employeur
    @GetMapping("/{userId}/accepted-or-rejected")
    public List<Publication> getUserPublicationsByAcceptedOrRejectedStatut(@PathVariable Long userId) {
        return publicationService.getUserPublicationsByAcceptedOrRejectedStatut(userId);
    }

    //Supprimer une publication
    @DeleteMapping("/{id}/delete")
    public ResponseEntity<String> deletePublication(@PathVariable("id") Long publicationId) {
        try {
            publicationService.deletePublication(publicationId);
            return ResponseEntity.ok("Publication supprimée avec succès.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Publication non trouvée avec ce id: " + publicationId);
        }
    }

    //Modifier une publication
    @PutMapping("/{id}/update")
    public ResponseEntity<Publication> updatePublication(@PathVariable("id") Long publicationId, @RequestBody Publication updatedPublication) {
        if (!publicationId.equals(updatedPublication.getId())) {
            return ResponseEntity.badRequest().build();
        }
        Publication updated = publicationService.updatePublication(updatedPublication);
        return ResponseEntity.ok(updated);
    }

    //Recherche de publication
    @GetMapping("/search")
    public ResponseEntity<List<PublicationWithUser>> searchPublicationsWithUser(
            @RequestParam String searchTerm) {
        List<PublicationWithUser> publicationsWithUsers = publicationService.searchPublicationsWithStatus(searchTerm);
        if (publicationsWithUsers.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(publicationsWithUsers);
    }
}