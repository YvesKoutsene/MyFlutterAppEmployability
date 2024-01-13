import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:essai/main.dart';


class PubStageEmploi extends StatefulWidget {
  @override
  _PubStageEmploiState createState() => _PubStageEmploiState();
}

class _PubStageEmploiState extends State<PubStageEmploi> {
  TextEditingController _titreController = TextEditingController();
  TextEditingController _dateOffreController = TextEditingController();
  TextEditingController _dateExpirationController = TextEditingController();
  TextEditingController _competencesController = TextEditingController();
  String _selectedRegion = '';
  String _selectedTypeOffre = '';
  TextEditingController _descriptionController = TextEditingController();
  int? _userID;

  DateTime? _selectedDate;
  DateTime? _selectedDateExpiration;

  List<String> _regions = ['', 'Maritime', 'Plateaux', 'Centrale', 'Kara', 'Savane'];
  List<String> _typeOffre = ['', 'Emploi', 'Stage'];

  String? _errorMessage;

  Future<void> _getUserID() async {
    final preferences = await SharedPreferences.getInstance();
    final userID = preferences.getInt('personId');
    setState(() {
      _userID = userID;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserID();
  }

  void _publishJobOrInternship() async {
    if (_userID == null ||
        _titreController.text.isEmpty ||
        _dateOffreController.text.isEmpty ||
        _selectedRegion.isEmpty ||
        _selectedTypeOffre.isEmpty ||
        _competencesController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs avant de soumettre.';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });

      try {
        String url = 'http://localhost:2003/publications/$_userID';
        Map<String, dynamic> requestBody = {
          'titre': _titreController.text,
          'dateOffre': _dateOffreController.text,
          'dateExpiration': _dateExpirationController.text,
          'statut': 'Attente',
          'region': _selectedRegion,
          'typeOffre': _selectedTypeOffre,
          'description': _descriptionController.text,
          'competences' : _competencesController.text,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          print('Formulaire soumis avec succès !');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Succès. Votre offre sera publiée après validation!'),
              duration: Duration(seconds: 5),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
          );
        } else {
          print('Échec de la soumission du formulaire. Code de réponse : ${response.statusCode}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La soumission du formulaire a échoué. Veuillez réessayer plus tard.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print('Une erreur s\'est produite lors de la soumission du formulaire : $e');

      }
    }
    _titreController.clear();
    _dateOffreController.clear();
    _competencesController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedRegion = '';
      _selectedTypeOffre= '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Page de publication',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 16.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titreController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du poste',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _dateOffreController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date de l\'offre',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      //lastDate: DateTime(DateTime.now().year + 5),
                      lastDate: DateTime.now(),

                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateOffreController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _dateExpirationController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date d\'expiration',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: tomorrow,
                      firstDate: tomorrow,
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDateExpiration = pickedDate;
                        _dateExpirationController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                ),

                const SizedBox(height: 16.0),
                TextField(
                  controller: _competencesController,
                  decoration: const InputDecoration(
                    labelText: 'Compétences requises',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRegion = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Région'),
                  items: _regions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedTypeOffre,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTypeOffre = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Type d\'offre'),
                  items: _typeOffre.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description du poste',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _publishJobOrInternship,
                  child: const Text('Publier'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(150, 40),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
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