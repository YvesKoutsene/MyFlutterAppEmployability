import 'dart:convert';

import 'package:essai/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:essai/main.dart';


class PasswordUpdate extends StatefulWidget {
  @override
  _PasswordUpdateState createState() => _PasswordUpdateState();
}

class _PasswordUpdateState extends State<PasswordUpdate> {
  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  bool _isLoading = false;
  bool passwordVisible = false;
  bool confPasswordVisible = false;


  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vérification de l\'e-mail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Un code a été envoyé à votre adresse e-mail.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: verificationCodeController,
                decoration: const InputDecoration(labelText: 'Saisir code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Valider'),
              onPressed: () {
                if (verificationCodeController.text.isNotEmpty) {
                  //Navigator.pop(context);
                  verifyAccount();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:2003/user/send-verification'),
        body: {'email': emailController.text},
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _showVerificationCodeDialog();
      } else if (response.statusCode == 400) {
        Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'];
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains(":")) {
        errorMessage = errorMessage.split(")")[1].trim();
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showErrorDialog(String errorMessage) {
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

  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
      ),
    );
  }


  Future<void> verifyAccount() async {
    final response = await http.post(
      Uri.parse('http://localhost:2003/user/verifyAccount'),
      body: {
        'email': emailController.text,
        'verificationCode': verificationCodeController.text,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte vérifié avec succès !'),
        ),
      );

      _showPasswordUpdateDialog();
    }
    else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Échec de vérification'),
            content: const Text('Le code de vérification est incorrect. Veuillez réessayer.'),
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
  }

  Future<void> updatePassword() async {
    final response = await http.post(
      Uri.parse('http://localhost:2003/user/updatePassword'),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
        'confpassword': confPasswordController.text,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre mot de passe a été changé avec succès, connectez-vous'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => true,
      );

    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Échec'),
            content: const Text('Changement de mot de passe échoué. Veuillez réessayer.'),
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
  }

  void _showPasswordUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Changer le mot de passe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !passwordVisible,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          confPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            confPasswordVisible = !confPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !confPasswordVisible,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Modifier'),
                  onPressed: () {
                    if (passwordController.text == confPasswordController.text) {
                      updatePassword();
                      Navigator.pop(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Erreur'),
                            content: const Text('Les mots de passe ne correspondent pas. Veuillez réessayer.'),
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
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reinitialisation de mot de passe'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Votre e-mail',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    String email = emailController.text;
                    if (email.isNotEmpty) {
                      sendVerificationCode();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const SizedBox(),
                        SizedBox(width: _isLoading ? 10 : 0),
                        const Text(
                          'Envoyer le Code',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
