import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:essai/main.dart';
import 'package:intl/intl.dart';

class DemandePage extends StatefulWidget {
  @override
  _DemandePageState createState() => _DemandePageState();
}

class _DemandePageState extends State<DemandePage> {
  TextEditingController presentationController = TextEditingController();
  String selectedType = '';
  String selectedDomaine = '';
  String selectedRegion = '';
  DateTime? selectedDate;
  List<int>? _cvBytes;
  String? _cvFilePath;
  bool _isCVUploaded = false;
  String? _errorMessage;
  bool _isSubmitting = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de service'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: presentationController,
              decoration: const InputDecoration(
                labelText: 'Présentation',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedType,
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              items: <String>['', 'Stage', 'Emploi', 'Autres']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Type de demande'),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedDomaine,
              onChanged: (newValue) {
                setState(() {
                  selectedDomaine = newValue!;
                });
              },
              items: <String>[
                '',
                'Agronomie',
                'Architecture',
                'Arts',
                'Chimie',
                'Marketing',
                'Gestion',
                'Droit',
                'Economie',
                'Géographie',
                'Histoire',
                'Informatique',
                'Ingénierie',
                'Lettre',
                'Mathématiques',
                'Médecine',
                'Physique',
                'Philosophie',
                'Psychologie',
                'Sociologie',
                'Sport',
                'Transport',
                'Autres'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Domaine'),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedRegion,
              onChanged: (newValue) {
                setState(() {
                  selectedRegion = newValue!;
                });
              },
              items: <String>[
                '',
                'Maritime',
                'Plateaux',
                'Centrale',
                'Kara',
                'Savane'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Region'),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: () async {
                DateTime? selected = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  //lastDate: DateTime(2050),
                  lastDate: DateTime.now(),

                );
                if (selected != null) {
                  setState(() {
                    selectedDate = selected;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de demande',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                    : "Sélectionnez une date"),
              ),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: () {
                _uploadCV();
              },
              child: const Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 15),
                  Text('Ajouter CV'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSubmitting ? null : (_isCVUploaded ? _submitForm : null),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Soumettre demande'),
            )

          ],
        ),
      ),
    );
  }

  Future<int?> _getUserID() async {
    final preferences = await SharedPreferences.getInstance();
    final userID = preferences.getInt('personId');
    return userID;
  }

  void _uploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'/*, 'docx', 'jpg', 'jpeg', 'png'*/],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      // Vérifier le type de fichier
      String extension = result.files.single.extension ?? '';
      if (extension == 'pdf' /*|| extension == 'docx' || extension == 'jpg' || extension == 'jpeg' || extension == 'png'*/) {
        List<int> bytes = await file.readAsBytes();

        setState(() {
          _cvBytes = bytes;
          _cvFilePath = result.files.single.path!;
          _isCVUploaded = true;
        });
      } else {
        // Afficher un message d'erreur si le type
      }
    }
  }


  void _submitForm() async {
    if (presentationController.text.isEmpty ||
        selectedDate == null ||
        selectedRegion == null ||
        selectedType == null ||
        selectedDomaine == null ||
        !_isCVUploaded) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs avant de soumettre.';
      });
    } else {
      setState(() {
        _errorMessage = null;
        _isSubmitting = true; // Début du chargement

      });

      try {
        final userID = await _getUserID();

        String url = 'http://localhost:2003/demandes/user/$userID';
        String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate!);

        Map<String, dynamic> requestBody = {
          'typeDemande': selectedType,
          'dateDemande': formattedDate,
          'region': selectedRegion,
          'domaine': selectedDomaine,
          'presentation': presentationController.text,
          'statut' : 'Demande en cours de traitement.\n Veuillez patienter 48h',
          'cvFile2': _cvBytes,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          // La soumission a réussi
          print('Formulaire soumis avec succès !');

          // Réinitialiser les chemins des fichiers
          _cvFilePath = '';
          _isCVUploaded = false;

          // Afficher un SnackBar avec le message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Votre demande a été soumise avec succès !'),
              duration: Duration(seconds: 5),
            ),
          );

          await Future.delayed(const Duration(seconds: 5));
          setState(() {
            _isSubmitting = false; // Fin du chargement
          });
          Navigator.pop(context);

        } else {
          // La soumission a échoué
          print(
              'Échec de la soumission du formulaire. Code de réponse : ${response
                  .statusCode}');

          // Afficher un SnackBar avec le message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'La soumission du formulaire a échoué. Veuillez réessayer plus tard.'),
              duration: Duration(seconds: 5),
            ),
          );

          await Future.delayed(const Duration(seconds: 5));
          setState(() {
            _isSubmitting = false; // Fin du chargement
          });
          Navigator.pop(context);


        }
      } catch (e) {
        print('Une erreur s\'est produite lors de la soumission du formulaire : $e');

        // Afficher un SnackBar avec un message d'erreur générique
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur s\'est produite lors de la soumission du formulaire. Veuillez réessayer plus tard.'),
            duration: Duration(seconds: 5),
          ),
        );

        // Rediriger vers HomePage() après 5 secondes
        await Future.delayed(const Duration(seconds: 5));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}