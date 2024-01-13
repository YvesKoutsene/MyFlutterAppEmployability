import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:essai/pagesupdate/ActivateCompte.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confPasswordController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();
  bool _passwordsMatch = true;
  bool _passwordVisible = false;
  bool _confPasswordVisible = false;
  bool _isButtonHovered = false;
  String _selectedProfile = '';
  bool _showEmptyFieldsMessage = false;
  bool _isLoading = false;


  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text == _confPasswordController.text;
    });
  }

  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vérification de l\'e-mail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Un code de validation a été envoyé à votre adresse e-mail.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _verificationCodeController,
                decoration: const InputDecoration(labelText: 'Saisir code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Code non réçu'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivateComptePage()),
                );
              },
            ),
            TextButton(
              child: const Text('Valider'),
              onPressed: () {
                if (_verificationCodeController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _finalRegister();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalRegister() async {
    setState(() {
      _isLoading = true;
    });

    String url = 'http://localhost:2003/user/register/final';

    Map<String, dynamic> requestBody = {
      'verificationCode': _verificationCodeController.text,
      'email': _emailController.text,
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // Afficher un Snackbar de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement réussi. Vous pouvez vous connecter!'),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });

    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Code de validation incorrect'),
            content: const Text('Veuillez réessayer'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  _showVerificationCodeDialog();
                },
              ),
            ],
          );
        },
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initialRegister() async {
    String url = 'http://localhost:2003/user/register';

    Map<String, dynamic> requestBody = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text,
      'confpassword': _confPasswordController.text,
      'profile': _selectedProfile,
      'verificationCode': _verificationCodeController.text,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _showVerificationCodeDialog();
      } else if (response.statusCode == 400) {
        Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Échec d\'Envoi'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains(":")) {
        errorMessage = errorMessage.split(")")[1].trim();
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Page d\'enregistrement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 16.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedProfile,
                  items: ['', 'Demandeur', 'Employeur'].map((profile) {
                    return DropdownMenuItem<String>(
                      value: profile,
                      child: Text(profile),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedProfile = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Profil'),
                ),
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
                    labelText: 'Adresse e-mail', icon: Icon(Icons.mail),
                  ),
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
                    prefixIcon: const Icon(Icons.lock), // Icône de clé pour le mot de passe
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    errorText: _passwordsMatch ? null : 'Les mots de passe ne correspondent pas',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confPasswordVisible = !_confPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_confPasswordVisible,
                  onChanged: (_) => _checkPasswordMatch(),
                ),
                const SizedBox(height: 16),
                if (_showEmptyFieldsMessage)
                  const Text(
                    'Veuillez remplir tous les champs',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                MouseRegion(
                  onEnter: (_) => setState(() => _isButtonHovered = true),
                  onExit: (_) => setState(() => _isButtonHovered = false),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      if (_lastNameController.text.isEmpty ||
                          _firstNameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _phoneNumberController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confPasswordController.text.isEmpty) {
                        setState(() {
                          _showEmptyFieldsMessage = true;
                        });
                      } else {
                        setState(() {
                          _isLoading = true;
                          _showEmptyFieldsMessage = false;
                        });

                        await _initialRegister();

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.green;
                          }
                          return null;
                        },
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                      'S\'enregistrer',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text('Déjà inscrit ? Se Connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
