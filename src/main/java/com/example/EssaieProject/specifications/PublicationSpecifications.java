package com.example.EssaieProject.specifications;

import com.example.EssaieProject.model.Publication;
import org.springframework.data.jpa.domain.Specification;

public class PublicationSpecifications {

    public static Specification<Publication> searchByCriteriaWithStatus(String searchTerm) {
        return (root, query, criteriaBuilder) -> criteriaBuilder.and(
                criteriaBuilder.equal(root.get("statut"), "Accepter"),
                criteriaBuilder.or(
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("titre")), "%" + searchTerm.toLowerCase() + "%"),
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("region")), "%" + searchTerm.toLowerCase() + "%"),
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("typeOffre")), "%" + searchTerm.toLowerCase() + "%"),
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("competences")), "%" + searchTerm.toLowerCase() + "%"),
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("description")), "%" + searchTerm.toLowerCase() + "%"),
                        criteriaBuilder.like(root.get("dateOffre"), "%" + searchTerm + "%")
                )
        );
    }
}