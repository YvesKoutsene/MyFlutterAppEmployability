import 'package:flutter/material.dart';
import 'package:essai/pub_post/pubStageEmploi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:essai/pagesinfo/Infoacceuil.dart';

class PublicationPage extends StatefulWidget {
  @override
  _PublicationPageState createState() => _PublicationPageState();
}

class _PublicationPageState extends State<PublicationPage> {
  bool _isHovered = false;
  int? _userID;
  String? _userProfile;
  bool _isUserLoggedIn = false;
  bool _isLoading = true;

  void _showConfirmationDialog() async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Vous avez une nouvelle offre?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Oui'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Non'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PubStageEmploi()),
      );
    }
  }

  Future<void> _getUserDataFromLocalStorage() async {
    final preferences = await SharedPreferences.getInstance();
    final userID = preferences.getInt('personId');
    final userProfile = preferences.getString('profile');

    setState(() {
      _userID = userID;
      _userProfile = userProfile;
      _isUserLoggedIn = (_userID != null && _userProfile != null);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserDataFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Recherche'),
      ),
      body: Center(
        child: Text('Bienvenue sur la page de recherche!'),
      ),
      floatingActionButton: _isUserLoggedIn && (_userProfile == "Employeur")
          ? FloatingActionButton(
        onPressed: _showConfirmationDialog,
        child: Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
