import 'package:essai/pub_post/Demande.dart';
import '../pub_post/Cv.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';
import '../auth/register.dart';
import 'package:essai/main.dart';
import 'package:essai/pagesupdate/updateProfil.dart';
import 'package:essai/pagesupdate/Admin.dart';
import 'package:essai/pagesleleng/notification.dart';


class ComptePage extends StatefulWidget {
  @override
  _ComptePageState createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  bool _isLogged = false;
  bool _isLoading = true;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _profile = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserProfile();
  }

  Future<void> _checkLoginStatus() async {
    final preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLogged = isLoggedIn;
      _isLoading = false;
    });
  }

  Future<void> _loadUserProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final firstName = preferences.getString('firstName') ?? '';
    final email = preferences.getString('email') ?? '';
    final lastName = preferences.getString('lastName') ?? '';
    final profile = preferences.getString('profile')?? '';

    setState(() {
      _firstName = firstName;
      _lastName = lastName;
      _email = email;
      _profile = profile;
    });
  }

  Future<void> _logout() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLoggedIn', false);
    await preferences.clear();

    setState(() {
      _isLogged = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        //content: Text('Déconnexion réussie!'),
        content: Text('Vous êtes deconnecté avec succès!'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  Widget _profileIcon() {
    IconData iconData;
    Color iconColor;

    switch (_profile) {
      case 'Administrateur':
        iconData = Icons.admin_panel_settings_rounded;
        iconColor = Colors.white;
        break;
      case 'Employeur':
        iconData = Icons.business_sharp;
        iconColor = Colors.white;
        break;
      case 'Demandeur':
        iconData = Icons.person_pin;
        iconColor = Colors.white;
        break;
      default:
        iconData = Icons.person;
        iconColor = Colors.white;
    }

    return Icon(
      iconData,
      size: 64.0,
      color: iconColor,
    );
  }

  Widget _nonConnectedIcon() {
    return const Icon(
      Icons.account_circle_outlined,
      size: 48.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Compte'),
        actions: [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Acceuil'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                );
              },
            ),

            if (_isLogged && _profile == 'Demandeur')
            ListTile(
              title: const Text('Génerer mon CV'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CvPage()),
                );
              },
            ),
            if (_isLogged && _profile == 'Demandeur')
            ListTile(
              title: const Text('Faire une demande'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DemandePage()),
                );
              },
            ),
            ListTile(
              title: const Text('Mon tableau de bord'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                      (route) => true,
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _isLogged
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.black38,
              radius: 45.0, //48
              child: _profileIcon(),
            ),
            const SizedBox(height: 20.0), //16

            Text(
              '$_profile !',
              style: const TextStyle(
                fontSize: 22.0, //24
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: const Text(
                    'Nom',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$_firstName $_lastName',
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: const Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$_email',
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: const Icon(
                    Icons.email,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_profile == "Employeur" || _profile == "Demandeur") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfilPage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPage(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: Text(_profile == "Employeur" || _profile == "Demandeur" ? 'Modifier le profil' : 'Ajouter admin'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 48.0,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Non connecté',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16.0),
            //de là
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text(
                'S\'enregistrer',
                style: TextStyle(fontSize: 13), //15
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text(
                'Se connecter',
                style: TextStyle(fontSize: 13), // 15
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            //à là

          ],
        ),
      ),
    );
  }
}
