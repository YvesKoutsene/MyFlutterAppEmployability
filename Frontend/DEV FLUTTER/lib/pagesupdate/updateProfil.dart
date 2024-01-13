import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../pagesleleng/compte.dart';
import 'package:essai/main.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class UpdateProfilPage extends StatefulWidget {
  @override
  _UpdateProfilPageState createState() => _UpdateProfilPageState();
}

class _UpdateProfilPageState extends State<UpdateProfilPage> {
  // Les contrôleurs pour les champs de saisie
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confPasswordController = TextEditingController();
  int? _userID;

  // Champ pour la couleur du bouton
  Color _buttonColor = Colors.blue;

  // Variable pour gérer l'affichage du mot de passe
  bool _isPasswordVisible = false;
  bool _isConfPasswordVisible = false;

  // Variable pour stocker l'état de validation des mots de passe
  bool _isPasswordValid = true;

  // Fonction pour récupérer les informations de l'utilisateur depuis le local storage
  Future<void> _getUserInfoFromLocalStorage() async {
    final preferences = await SharedPreferences.getInstance();
    final userID = preferences.getInt('personId');
    final firstName = preferences.getString('firstName');
    final lastName = preferences.getString('lastName');
    final email = preferences.getString('email');
    final phoneNumber = preferences.getString('phoneNumber');
    final password = preferences.getString('password');
    final confPassword = preferences.getString('confpassword');

    setState(() {
      _userID = userID;
      _firstNameController.text = firstName ?? '';
      _lastNameController.text = lastName ?? '';
      _emailController.text = email ?? '';
      _phoneNumberController.text = phoneNumber ?? '';
      _passwordController.text = password ?? '';
      _confPasswordController.text = confPassword ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserInfoFromLocalStorage();
  }

  bool _arePasswordsValid() {
    String password = _passwordController.text;
    String confPassword = _confPasswordController.text;

    return password == confPassword;
  }

  // Fonction pour mettre à jour le profil de l'utilisateur
  Future<void> _handleUpdateProfile() async {
    if (!_arePasswordsValid()) {
      setState(() {
        _isPasswordValid = false;
      });
      return;
    }

    setState(() {
      _isPasswordValid = true;
    });

    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    String phoneNumber = _phoneNumberController.text;
    String password = _passwordController.text;
    String confPassword = _confPasswordController.text;

    final url = 'http://localhost:2003/user/$_userID';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confpassword': confPassword,
      }),
    );

    if (response.statusCode == 200) {
      final preferences = await SharedPreferences.getInstance();
      preferences.setString('firstName', firstName);
      preferences.setString('lastName', lastName);
      preferences.setString('email', email);
      preferences.setString('phoneNumber', phoneNumber);
      preferences.setString('password', password);
      preferences.setString('confpassword', confPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Porfil mise à jour avec succès.'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );

    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Une erreur est survenue lors de la mise à jour du profil.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Mettre à jour profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 16.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),
                IntlPhoneField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                  ),
                  initialCountryCode: 'TG',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _confPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isConfPasswordVisible = !_isConfPasswordVisible;
                        });
                      },
                      icon: Icon(_isConfPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  obscureText: !_isConfPasswordVisible,
                ),

                if (!_isPasswordValid)
                  const Text(
                    'Les mots de passe ne correspondent pas.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 32),
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _buttonColor = Colors.green;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _buttonColor = Colors.blue;
                    });
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      _handleUpdateProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: _buttonColor, // Couleur du bouton
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Taille du bouton
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Border radius personnalisé
                      ),
                    ),
                    child: const Text('Modifier profil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}