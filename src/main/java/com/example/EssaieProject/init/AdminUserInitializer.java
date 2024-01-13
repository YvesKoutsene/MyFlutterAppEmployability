package com.example.EssaieProject.init;
import com.example.EssaieProject.model.User;
import com.example.EssaieProject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class AdminUserInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Vérification si un utilisateur administrateur existe déjà
        if (!userRepository.existsByProfile("Administrateur")) {
            // Création d'un nouvel utilisateur administrateur
            User adminUser = new User();
            adminUser.setFirstName("Cnej");
            adminUser.setLastName("Admin");
            adminUser.setEmail("lenoirkevin312@gmail.com");
            adminUser.setPhoneNumber("93816766");
            adminUser.setProfile("Administrateur");
            adminUser.setIsactivate(true);
            adminUser.setVerificationCode("2508");

            //adminUser.setPassword(passwordEncoder.encode("admin01234"));
            adminUser.setPassword("admin01234");
            adminUser.setConfpassword("admin01234");
            userRepository.save(adminUser);
        }
    }
}
