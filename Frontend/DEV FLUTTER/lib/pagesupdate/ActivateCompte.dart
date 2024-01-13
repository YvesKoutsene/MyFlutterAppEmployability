import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:essai/auth/login.dart';


class ActivateComptePage extends StatefulWidget {
  @override
  _ActivateComptePageState createState() => _ActivateComptePageState();
}

class _ActivateComptePageState extends State<ActivateComptePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  bool _isLoading = false;


  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vérification de l\'e-mail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Un nouveau code a été envoyé à votre adresse e-mail.'),
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
                  Navigator.pop(context);
                  verifyCodeAndActivate();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> resendVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://localhost:2003/user/resend-verification'),
      body: {'email': emailController.text},
    );

    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      _showVerificationCodeDialog();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Échec d\'Envoi'),
            content: const Text('Le renvoi du code de vérification a échoué. Veuillez réessayer.'),
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

  Future<void> verifyCodeAndActivate() async {
    final response = await http.post(
      Uri.parse('http://localhost:2003/user/activate-account'),
      body: {
        'email': emailController.text,
        'verificationCode': verificationCodeController.text,
      },
    );

    if (response.statusCode == 200) {
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
        builder: (context) {
          return AlertDialog(
            title: const Text('Échec d\'Activation'),
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


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Activation de Compte'),
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
                        hintText: 'Retapez votre e-mail',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Désactive le bouton pendant le chargement
                      : () {
                    String email = emailController.text;
                    if (email.isNotEmpty) {
                      resendVerificationCode();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const CircularProgressIndicator() // Indicateur de chargement
                            : const SizedBox(),
                        SizedBox(width: _isLoading ? 10 : 0), // Espacement si l'indicateur de chargement est affiché
                        const Text(
                          'Renvoyer le Code',
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

