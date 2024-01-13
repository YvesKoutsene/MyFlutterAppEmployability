package com.example.EssaieProject.service;
import com.example.EssaieProject.model.*;
import com.example.EssaieProject.repository.PublicationRepository;
import com.example.EssaieProject.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.EssaieProject.repository.PostulationRepository;
import java.util.Optional;

@Service
public class PostulationService {

    private final UserRepository userRepository;
    private final PublicationRepository publicationRepository;

    private final PostulationRepository postulationRepository;

    @Autowired
    public PostulationService(PostulationRepository postulationRepository,  UserRepository userRepository,PublicationRepository publicationRepository) {
        this.postulationRepository = postulationRepository;
        this.userRepository =userRepository;
        this.publicationRepository = publicationRepository;
    }

    public Postulation savePostulation(Postulation postulation) {
        return postulationRepository.save(postulation);
    }

    //Afficher les postulations d'une offre d'un user
    public List<PostulationWithPublicationWithUser> getAllPostulationsForEmployer(Long employerId) {
        List<Postulation> postulations = postulationRepository.findByPublicationUser2IdAndStatutNotIn(employerId);
        List<PostulationWithPublicationWithUser> postulationWithPublicationWithUsers = new ArrayList<>();

        for (Postulation postulation : postulations) {
            postulationWithPublicationWithUsers.add(
                    new PostulationWithPublicationWithUser(
                            postulation,
                            postulation.getPublication(),
                            postulation.getUser()
                    )
            );
        }
        return postulationWithPublicationWithUsers;
    }

    //Valider une postulation
    public void validerStatut(Long postulationId) {
        Postulation postulation = postulationRepository.findById(postulationId).orElse(null);
        if (postulation != null) {
            postulation.setStatut("Accepter");
            postulationRepository.save(postulation);
        }
    }

    public void rejeterStatut(Long postulationId) {
        Postulation postulation = postulationRepository.findById(postulationId).orElse(null);
        if (postulation != null) {
            postulation.setStatut("Rejeter");
            postulationRepository.save(postulation);
        }
    }

    //Afficher les postulations ayant un statut accepter ou rejeter d'un user
    public List<Postulation> getPostulationsByUserIdAndAcceptedOrRejected(Long userId) {
        List<String> statut = Arrays.asList("Accepter", "Rejeter");
        return postulationRepository.findByUser_IdAndStatutIn(userId, statut);
    }

    //New
    public List<PostulationWithPublication> getPostulationsWithPublications(Long userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();

            List<Postulation> postulations = user.getPostulations();

            List<PostulationWithPublication> result = new ArrayList<>();
            List<String> predefinedStatuts = Arrays.asList("Accepter", "Rejeter", "Attente");

            for (Postulation postulation : postulations) {
                if (predefinedStatuts.contains(postulation.getStatut())) { // Vérifie le statut de la postulation
                    Publication publication = postulation.getPublication();
                    PostulationWithPublication dto = new PostulationWithPublication();
                    dto.setPostulation(postulation);
                    dto.setPublication(publication);
                    result.add(dto);
                }
            }
            return result;
        } else {
            throw new EntityNotFoundException("User non trouvé avec cet Id: " + userId);
        }
    }

    public void deletePostulation(Long postulationId) {
        Postulation postulation = postulationRepository.findById(postulationId)
                .orElseThrow(() -> new IllegalArgumentException("Postulation not found with ID: " + postulationId));
        postulationRepository.delete(postulation);
    }

    public Optional<Postulation> getPostulationById(Long id) {
        return postulationRepository.findById(id);
    }

    //Afficher les postulations d'une publication
    //New
    public List<PostulationWithUser> getPostulationsWithUsersByPublicationId(Long publicationId) {
        List<PostulationWithUser> postulationsWithUsers = new ArrayList<>();

        Optional<Publication> publicationOptional = publicationRepository.findById(publicationId);
        if (publicationOptional.isPresent()) {
            Publication publication = publicationOptional.get();
            List<Postulation> postulations = publication.getPostulations();

            for (Postulation postulation : postulations) {
                User user = postulation.getUser();
                postulationsWithUsers.add(new PostulationWithUser(postulation, user));
            }
        } else {
            throw new EntityNotFoundException("Publication non trouvée avec cet Id : " + publicationId);
        }
        return postulationsWithUsers;
    }

}
