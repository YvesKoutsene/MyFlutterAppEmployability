package com.example.EssaieProject.controller;
import ch.qos.logback.core.net.LoginAuthenticator;
import com.example.EssaieProject.model.User;
import com.example.EssaieProject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import com.example.EssaieProject.model.LoginRequest;

@Controller
@RestController
@RequestMapping("user")
public class UserController {
    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }


    public boolean validateVerificationCode(User user, String inputVerificationCode) {
        return user.getVerificationCode().equals(inputVerificationCode);
    }

    @PostMapping("/register")
    public ResponseEntity<String> registerUser(@RequestBody User request) {
        try {
            userService.registerUserWithVerification(request);
            return ResponseEntity.ok("User enrégistré avec succès. Code de vérification envoyé à l'email");
        }
        catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    //New 777
    @PostMapping("/register/final")
    public ResponseEntity<String> registerUserFinal(@RequestBody VerificationCodeRequest request) {
        try {
            User user = userService.getUserByEmail(request.getEmail());
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Utilisateur introuvable");
            }

            if (!userService.validateVerificationCode(user, request.getVerificationCode())) {
                return ResponseEntity.badRequest().body("Code de vérification incorrect");
            }

            // Effectuer les étapes finales d'enregistrement ici
            userService.performFinalRegistration(user);

            return ResponseEntity.ok("Enregistrement final réussi");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur lors de l'enregistrement final");
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        String email = loginRequest.getEmail();
        String password = loginRequest.getPassword();

        // Appel de la fonction de connexion dans le service utilisateur
        User user = userService.login(email, password);

        if (user != null) {
            // Connexion réussie, retournez l'utilisateur connecté
            return ResponseEntity.ok(user);
        } else {
            // Connexion échouée, retournez une erreur ou une réponse appropriée
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Echec de l'authentification");
        }
    }

    //Mise à jour l'utilisateur par son ID
    @PutMapping("/{userId}")
    public ResponseEntity<User> updateUser(@PathVariable Long userId, @RequestBody User updatedUser) {
        User updatedUserInfo = userService.updateUser(userId, updatedUser);
        return new ResponseEntity<>(updatedUserInfo, HttpStatus.OK);
    }

    //Afficher l'user par son identifiant
    @GetMapping("getuser/{userId}")
    public ResponseEntity<User> getUserById(@PathVariable Long userId) {
        User user = userService.getUserById(userId);
        return ResponseEntity.ok(user);
    }

    //Ajout d'admin
    @PostMapping("/add-admin")
    public User addAdminUser(@RequestBody User user) {
        return userService.addUserWithDefaults(user);
    }

    //Renvoie du code de validation
    @PostMapping("/resend-verification")
    public ResponseEntity<String> resendVerificationCode(@RequestParam String email) {
        try {
            userService.resendVerificationCode(email);
            return ResponseEntity.ok("Code de vérification renvoyé avec succès");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("L'utilisateur avec l'email spécifié n'existe pas");
        }
    }

    // Endpoint pour activer le compte
    @PostMapping("/activate-account")
    public ResponseEntity<String> activateAccount(@RequestParam String email, @RequestParam String verificationCode) {
        boolean isActivated = userService.activateAccount(email, verificationCode);
        if (isActivated) {
            return ResponseEntity.ok("Compte activé avec succès");
        } else {
            return ResponseEntity.badRequest().body("Échec de l'activation du compte. Vérifiez l'email et le code de vérification.");
        }
    }

    //Renvoie du code de validation
    @PostMapping("/send-verification")
    public ResponseEntity<String> sendVerificationCode(@RequestParam String email) {
        try {
            userService.sendVerificationCode(email);
            return ResponseEntity.ok("Code de vérification email envoyé avec succès");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("L'utilisateur avec l'email spécifié n'existe pas");
        }
    }

    //Verfication de compte
    @PostMapping("/verifyAccount")
    public ResponseEntity<String> verifyAccount(
            @RequestParam String email,
            @RequestParam String verificationCode) {
        boolean verificationSuccess = userService.verifyAccount(email, verificationCode);

        if (verificationSuccess) {
            return ResponseEntity.ok("Compte vérifié avec succès !");
        } else {
            return ResponseEntity.badRequest().body("Échec de la vérification du compte.");
        }
    }

    //Modification de mot de passe
    @PostMapping("/updatePassword")
    public void updatePasswordAndConfPassword(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String confpassword) {
        userService.updatePasswordAndConfPasswordByEmail(email, password, confpassword);
    }

}

