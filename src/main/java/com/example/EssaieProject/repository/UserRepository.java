package com.example.EssaieProject.repository;
import com.example.EssaieProject.model.User;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserRepository extends CrudRepository<User, Long>{
    boolean existsByEmail(String email);
    User findByEmail(String email);
    boolean existsByProfile(String profile);

    User findByEmailAndVerificationCode(String userEmail, String verificationCode);

    List<User> findByProfile(String profile);
}
