package com.example.EssaieProject.service;
import com.example.EssaieProject.model.PublicationWithUser;
import com.example.EssaieProject.exception.NotFoundException;
import com.example.EssaieProject.model.Postulation;
import com.example.EssaieProject.model.Publication;
import com.example.EssaieProject.model.User;
import com.example.EssaieProject.repository.PostulationRepository;
import com.example.EssaieProject.repository.PublicationRepository;
import com.example.EssaieProject.repository.UserRepository;
import com.example.EssaieProject.specifications.PublicationSpecifications;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class PublicationService {

    private final PublicationRepository publicationRepository;

    @Autowired
    public PublicationService(PublicationRepository publicationRepository) {
        this.publicationRepository = publicationRepository;
    }

    //faire une publication
    public Publication savePublication(Publication publication) {
        return publicationRepository.save(publication);
    }

    //afficher toutes les publiations "accepter"
    public List<Publication> getAllAcceptedPublications() {
        return publicationRepository.findByStatut("Accepter");
    }

    public List<PublicationWithUser> getAllAcceptedPublicationsWithUser() {
        List<Publication> acceptedPublications = publicationRepository.findByStatut("Accepter");
        List<PublicationWithUser> publicationsWithUsers = new ArrayList<>();

        for (Publication publication : acceptedPublications) {
            User user = publication.getUser2();

            PublicationWithUser publicationWithUser = new PublicationWithUser(publication, user);
            publicationsWithUsers.add(publicationWithUser);
        }

        return publicationsWithUsers;
    }

    //afficher toutes les publications "avec statut Attente"
    public List<Publication> getPublicationsWithStatus(String status) {
        return publicationRepository.findByStatut(status);
    }

    //Postuler à une offre
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private PostulationRepository postulationRepository;
    public Postulation postuler(Long userId, Long publicationId, Postulation postulation) {
       Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();

            Optional<Publication> publicationOptional = publicationRepository.findById(publicationId);
            if (publicationOptional.isPresent()) {
                Publication publication = publicationOptional.get();
                postulation.setPublication(publication);
                postulation.setUser(user);
                return postulationRepository.save(postulation);
            } else {
                throw new EntityNotFoundException("Publication non trouvée avec cet Id : " + publicationId);
            }
        } else {
            throw new EntityNotFoundException("User non trouvé avec cet Id: " + userId);
        }
    }
    //Validation d'une publication "accepter" ou "refuser"
    public Publication getPublicationById(Long id) {
        return publicationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Publication non trouvée"));
    }
    public void validatePublication(Long id) {
        Publication publication = getPublicationById(id);
        publication.setStatut("Accepter");
        publicationRepository.save(publication);
    }
    public void rejectPublication(Long id) {
        Publication publication = getPublicationById(id);
        publication.setStatut("Rejeter");
        publicationRepository.save(publication);
    }
    public List<Publication> getUserPublicationsByAcceptedOrRejectedStatut(Long userId) {
        return publicationRepository.findByUser2IdAndStatutIn(userId, List.of("Accepter", "Rejeter", "Attente"));
    }

    //Supprimer une publication
    public void deletePublication(Long publicationId) {
        Publication publication = publicationRepository.findById(publicationId)
                .orElseThrow(() -> new IllegalArgumentException("Publication not found with ID: " + publicationId));

        publicationRepository.delete(publication);
    }

    //Modifier une publication
    public Publication updatePublication(Publication updatedPublication) {
        Publication existingPublication = publicationRepository.findById(updatedPublication.getId())
                .orElseThrow(() -> new IllegalArgumentException("Publication non trouvée avec l'ID: " + updatedPublication.getId()));
        existingPublication.setTitre(updatedPublication.getTitre());
        existingPublication.setDateOffre(updatedPublication.getDateOffre());
        existingPublication.setTypeOffre(updatedPublication.getTypeOffre());
        existingPublication.setCompetences(updatedPublication.getCompetences());
        existingPublication.setRegion(updatedPublication.getRegion());
        existingPublication.setStatut("Attente");
        existingPublication.setDateExpiration(updatedPublication.getDateExpiration());
        existingPublication.setDescription(updatedPublication.getDescription());

        return publicationRepository.save(existingPublication);
    }

    //Recherche de publication
    /*public List<PublicationWithUser> searchPublicationsWithStatus(String searchTerm) {
        Specification<Publication> specification = PublicationSpecifications.searchByCriteriaWithStatus(searchTerm);
        List<Publication> publications = publicationRepository.findAll(specification);

        List<PublicationWithUser> publicationsWithUsers = new ArrayList<>();
        for (Publication publication : publications) {
            User user = publication.getUser2();
            publicationsWithUsers.add(new PublicationWithUser(publication, user));
        }

        return publicationsWithUsers;
    }*/

    public List<PublicationWithUser> searchPublicationsWithStatus(String searchTerm) {
        Specification<Publication> specification = PublicationSpecifications.searchByCriteriaWithStatus(searchTerm);
        List<Publication> publications = publicationRepository.findAll(specification);

        List<PublicationWithUser> publicationsWithUsers = new ArrayList<>();
        if (!publications.isEmpty()) {
            for (Publication publication : publications) {
                User user = publication.getUser2();
                publicationsWithUsers.add(new PublicationWithUser(publication, user));
            }
        } else {
            String message = "Aucune publication trouvée.";
            publicationsWithUsers.add(new PublicationWithUser(message));
        }

        return publicationsWithUsers;
    }
}
