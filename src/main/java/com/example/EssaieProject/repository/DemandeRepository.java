package com.example.EssaieProject.repository;

import com.example.EssaieProject.model.Demande;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DemandeRepository extends JpaRepository<Demande, Long> {
    List<Demande> findByRegion(String region);
    List<Demande> findByUser3Id(Long userId);
}
