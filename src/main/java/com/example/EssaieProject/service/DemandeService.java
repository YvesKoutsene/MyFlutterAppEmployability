package com.example.EssaieProject.service;

import com.example.EssaieProject.model.Demande;
import com.example.EssaieProject.repository.DemandeRepository;
import com.example.EssaieProject.repository.PublicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DemandeService {

    private final DemandeRepository demandeRepository;
    @Autowired
    public DemandeService(DemandeRepository demandeRepository) {
        this.demandeRepository = demandeRepository;
    }

    // Faire une demande de service
    public Demande createDemande(Demande demande) {
        return demandeRepository.save(demande);
    }

    // Afficher les demandes par region
    public List<Demande> getDemandesByRegion(String region) {
        return demandeRepository.findByRegion(region);
    }

    //Afficher les demandes par utilisateur
    public List<Demande> getDemandesByUserId(Long userId) {
        return demandeRepository.findByUser3Id(userId);
    }

    //Supprimer une demande
    public void deleteDemande(Long demandeId) {
        Demande demande = demandeRepository.findById(demandeId)
                .orElseThrow(() -> new IllegalArgumentException("Demande not found with ID: " + demandeId));

        demandeRepository.delete(demande);
    }

}
