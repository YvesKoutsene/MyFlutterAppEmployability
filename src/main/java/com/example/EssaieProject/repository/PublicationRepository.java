package com.example.EssaieProject.repository;

import com.example.EssaieProject.model.Publication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
//public interface PublicationRepository extends JpaRepository<Publication, Long> {
public interface PublicationRepository extends JpaRepository<Publication, Long>, JpaSpecificationExecutor<Publication> {
    List<Publication> findByStatut(String statut);
    List<Publication> findByUser2IdAndStatutIn(Long userId, List<String> accepter);
}
