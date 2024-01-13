package com.example.EssaieProject.repository;

import com.example.EssaieProject.model.Postulation;
import com.example.EssaieProject.model.Publication;
import com.example.EssaieProject.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PostulationRepository extends JpaRepository<Postulation, Long> {
   @Query("SELECT p FROM Postulation p WHERE p.publication.user2.id = ?1 AND p.statut NOT IN ('Accepter', 'Rejeter')")
    List<Postulation> findByPublicationUser2IdAndStatutNotIn(Long employerId);

    @Modifying
    @Query("UPDATE Postulation p SET p.statut = 'Accepter' WHERE p.id = :postulationId")
    void validerStatut(Long postulationId);

    @Modifying
    @Query("UPDATE Postulation p SET p.statut = 'Rejeter' WHERE p.id = :postulationId")
    void rejeterStatut(Long postulationId);

    List<Postulation> findByUser_IdAndStatutIn(Long userId, List<String> statut);

    //New 777

}
