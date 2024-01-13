package com.example.EssaieProject.service;
import com.example.EssaieProject.exception.EmailConnectionException;
import com.example.EssaieProject.exception.EmailNotFoundException;
import com.example.EssaieProject.exception.EmailNotSentException;
import com.example.EssaieProject.exception.UserNotFoundException;
import com.example.EssaieProject.model.User;
import com.example.EssaieProject.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;


@Service
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;

    @Autowired
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }

    public User registerUserWithVerification(User user) {
        if (user == null) {
            throw new IllegalArgumentException("L'utilisateur ne peut pas être null");
        }

        validateUser(user);
        user.setId(generateUniqueId());
        String verificationCode = generateVerificationCode();

        String subject = "Vérification de votre adresse e-mail";
        String text = verificationCode + " : Votre code de validation Compte";
        emailService.sendVerificationEmail(user.getEmail(), subject, text);

        user.setVerificationCode(verificationCode);
        User savedUser = userRepository.save(user);
        return savedUser;
    }

    public boolean validateVerificationCode(User user, String verificationCode) {
        String storedCode = user.getVerificationCode();
        return storedCode != null && storedCode.equals(verificationCode);
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public void performFinalRegistration(User user) {
        user.setIsactivate(true);
        userRepository.save(user);
    }

    private void validateUser(User user) {
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Adresse e-mail déjà enregistrée");
        }

        if (!isValidPassword(user.getPassword())) {
            throw new IllegalArgumentException("Le mot de passe doit comporter au moins 8 caractères");
        }

        /*if (!isValidProfile(user.getProfile())) {
            throw new IllegalArgumentException("Profil invalide");
        }*/
    }

    private boolean isValidPassword(String password) {
        return password.length() >= 8;
    }

    /*private boolean isValidProfile(String profile) {
        return profile.equals("Employeur") || profile.equals("Demandeur");
    }*/

    private Long generateUniqueId() {
        return System.currentTimeMillis();
    }

    private String generateVerificationCode() {
        Random random = new Random();
        int code = random.nextInt(9000) + 1000;
        return String.valueOf(code);
    }


    public User login(String email, String password) {
        User user = userRepository.findByEmail(email);
        if (user != null && password.equals(user.getPassword())) {
            if (user.isIsactivate()) {
                return user;
            } else {
                throw new IllegalArgumentException("Votre compte est inactif. Veuillez contacter l'administrateur.");
            }
        } else {
            return null;
        }
    }

    // Afficher l'utilisateur par son id
    public User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("L'utilisateur avec l'ID " + userId + " n'a pas été trouvé."));
    }

    // Mise à jour de l'utilisateur
    public User updateUser(Long userId, User updatedUser) {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable"));
        existingUser.setFirstName(updatedUser.getFirstName());
        existingUser.setLastName(updatedUser.getLastName());
        existingUser.setEmail(updatedUser.getEmail());
        existingUser.setPhoneNumber(updatedUser.getPhoneNumber());
        existingUser.setPassword(updatedUser.getPassword());
        existingUser.setConfpassword(updatedUser.getConfpassword());

        return userRepository.save(existingUser);
    }

    //Ajout d'admin
    @Transactional
    public User addUserWithDefaults(User user) {
        user.setProfile("Administrateur");
        user.setIsactivate(true);
        user.setVerificationCode("0911");
        validateUser(user);

        return userRepository.save(user);
    }

    //Fonction de renvoie de code de vérification
    public void resendVerificationCode(String userEmail) {
        User user = userRepository.findByEmail(userEmail);
        if (user != null) {
            String verificationCode = generateVerificationCode();
            user.setVerificationCode(verificationCode);
            userRepository.save(user);

            String subject = "Code de vérification";
            String text = verificationCode + " : Votre nouveau code de validation Compte";
            emailService.sendVerificationEmail(user.getEmail(), subject, text);
        } else {
            throw new IllegalArgumentException("L'utilisateur avec l'email spécifié n'existe pas");
        }
    }

    //Fonction d'activation d'email
    public boolean activateAccount(String userEmail, String verificationCode) {
        User user = userRepository.findByEmailAndVerificationCode(userEmail, verificationCode);
        if (user != null) {
            user.setIsactivate(true);
            userRepository.save(user);
            return true;
        } else {
            return false;
        }
    }

    //Recherche d'admin dans la base de données
    public List<String> getAdminEmails() {
        List<User> adminUsers = userRepository.findByProfile("Administrateur");
        List<String> adminEmails = adminUsers.stream()
                .map(User::getEmail)
                .collect(Collectors.toList());
        return adminEmails;
    }


    //Fonction d'envoie de code email
    public void sendVerificationCode(String userEmail) {
        User user = userRepository.findByEmail(userEmail);
        if (user != null) {
            String verificationCode = generateVerificationCode();
            user.setVerificationCode(verificationCode);
            userRepository.save(user);

            String subject = "Code de vérification";
            String text = verificationCode + " : Votre code de vérification email";
            emailService.sendVerificationEmail(user.getEmail(), subject, text);
        } else {
            throw new IllegalArgumentException("L'utilisateur avec l'email spécifié n'existe pas");
        }
    }

    //Fonction de validation d'email
    public boolean verifyAccount(String userEmail, String verificationCode) {
        User user = userRepository.findByEmailAndVerificationCode(userEmail, verificationCode);
        if (user != null) {
            userRepository.save(user);
            return true;
        } else {
            return false;
        }
    }

    //Modification de mot de passe
    public void updatePasswordAndConfPasswordByEmail(String email, String password, String confpassword) {
        User user = userRepository.findByEmail(email);

        if (user != null) {
            user.setPassword(password);
            user.setConfpassword(confpassword);
            userRepository.save(user);
        } else {
            throw new RuntimeException("Utilisateur non trouvé avec l'e-mail: " + email);
        }
    }

}
