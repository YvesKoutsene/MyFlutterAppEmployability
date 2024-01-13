import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:essai/main.dart';
import 'register.dart';
import 'package:essai/pagesupdate/PasswordUpdate.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  bool _isButtonHovered = false;
  bool _isCreateAccountHovered = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    const String apiUrl = 'http://localhost:2003/user/login';

    final Map<String, String> requestData = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      final personId = responseData['id'];
      final firstName = responseData['firstName'] ?? '';
      final lastName = responseData['lastName'] ?? '';
      final phoneNumber = responseData['phoneNumber'] ?? '';
      final confpassword = responseData['confpassword'] ?? '';
      final profile = responseData['profile'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentification réussie avec succès!'),
          duration: Duration(seconds: 5),
        ),
      );

      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('id', personId);
      await preferences.setString('email', _emailController.text);
      await preferences.setString('password', _passwordController.text);
      await preferences.setInt('personId', personId);
      await preferences.setString('firstName', firstName);
      await preferences.setString('lastName', lastName);
      await preferences.setString('phoneNumber', phoneNumber);
      await preferences.setString('confpassword', confpassword);
      await preferences.setString('profile', profile);
      preferences.setBool('isLoggedIn', true);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );

    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Echec d\'authentification'),
            content: const Text('Mot de passe ou adresse e-mail incorrect'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString('email');
    final password = preferences.getString('password');

    if (email != null && password != null) {
      setState(() {
        _emailController.text = email;
        _passwordController.text = password;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Page de connexion'),
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
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Adresse e-mail',
                    icon: Icon(Icons.mail),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
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

                const SizedBox(height: 24),
                MouseRegion(
                  onEnter: (_) => setState(() => _isButtonHovered = true),
                  onExit: (_) => setState(() => _isButtonHovered = false),
                  child: ElevatedButton(
                    onPressed: login,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(const Size(200, 48)),
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.green;
                          }
                          return null;
                        },
                      ),
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MouseRegion(
                  onEnter: (_) => setState(() => _isCreateAccountHovered = true),
                  onExit: (_) => setState(() => _isCreateAccountHovered = false),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.green;
                          }
                          return null;
                        },
                      ),
                    ),
                    child: const Text('Créer un compte'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordUpdate()),
                    );
                  },
                  child: const Text('Mot de passe oublié',
                  style: TextStyle(
                    color: Colors.green,
                  ),
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
