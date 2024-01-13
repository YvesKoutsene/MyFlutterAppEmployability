import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:essai/main.dart';
import 'package:essai/pagesleleng/acceuil.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';



class PostStageEmploi extends StatefulWidget {
  final Publication publication;
  PostStageEmploi(this.publication);

  @override
  _PostStageEmploiState createState() => _PostStageEmploiState();
}

class _PostStageEmploiState extends State<PostStageEmploi> {
  int? id;
  DateTime? _datePostulation;
  List<int>? _cvBytes;
  List<int>? _lettreMotivationBytes;
  String _cvFilePath = '';
  String _lettreMotivationFilePath = '';
  bool _isCVUploaded = false;
  bool _isLettreMotivationUploaded = false;
  bool _isBacSelected = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    id = widget.publication.id;
  }

  Future<int?> _getUserID() async {
    final preferences = await SharedPreferences.getInstance();
    final userID = preferences.getInt('personId');
    return userID;
  }

  void _uploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      String extension = path.extension(file.path).toLowerCase();

      if (extension == '.pdf' || extension == '.doc' || extension == '.docx' || extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
        List<int> bytes = await file.readAsBytes();

        setState(() {
          _cvBytes = bytes;
          _cvFilePath = result.files.single.path!;
          _isCVUploaded = true;
        });
      } else {
      }
    }
  }

  void _uploadLettreMotivation() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      String extension = path.extension(file.path).toLowerCase();

      if (extension == '.pdf' || extension == '.doc' || extension == '.docx' || extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
        List<int> bytes = await file.readAsBytes();

        setState(() {
          _lettreMotivationBytes = bytes;
          _lettreMotivationFilePath = result.files.single.path!;
          _isLettreMotivationUploaded = true;
        });
      } else {
      }
    }
  }

  void _submitForm() async {
    if (_datePostulation == null ||
        !_isCVUploaded ||
        !_isLettreMotivationUploaded) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs avant de soumettre.';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });

      try {
        final userID = await _getUserID();

        String url = 'http://localhost:2003/publications/users/$userID/publications/$id/postulations';
        String formattedDate = DateFormat('dd-MM-yyyy').format(_datePostulation!);

        Map<String, dynamic> requestBody = {
          'datePostulation': formattedDate,
          'statut' : 'Attente',
          'cvFile': _cvBytes,
          'lettreMotivationFile': _lettreMotivationBytes,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Votre candidature a été soumise avec succès !'),
              duration: Duration(seconds: 5),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'La soumission du formulaire a échoué. Veuillez réessayer plus tard.'),
              duration: Duration(seconds: 5),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur s\'est produite lors de la soumission du formulaire. Veuillez réessayer plus tard.'),
            duration: Duration(seconds: 5),
          ),
        );
        await Future.delayed(const Duration(seconds: 5));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Page de candidature',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: const Text('Date de candidature'),
                  subtitle: _datePostulation == null
                      ? const Text('Choisir date')
                      : Text('${DateFormat('dd/MM/yyyy').format(_datePostulation!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now(),
                    );

                    if (selectedDate != null) {
                      setState(() {
                        _datePostulation = selectedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return _isCVUploaded ? Colors.grey : Colors.grey;
                              }
                              return _isCVUploaded ? Colors.grey : Colors.blueGrey;
                            },
                          ),
                        ),
                        onPressed: _isCVUploaded ? null : _uploadCV,
                        icon: Icon(Icons.file_upload, color: Colors.grey[400]),
                        label: Text(_isCVUploaded ? 'CV ajouté' : 'Ajouter CV'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return _isLettreMotivationUploaded ? Colors.grey : Colors.grey;
                              }
                              return _isLettreMotivationUploaded ? Colors.grey : Colors.blueGrey;
                            },
                          ),
                        ),
                        onPressed: _isLettreMotivationUploaded ? null : _uploadLettreMotivation,
                        icon: Icon(Icons.file_upload, color: Colors.grey[400]),
                        label: Text(_isLettreMotivationUploaded ? 'Lettre ajoutée' : 'Ajouter lettre'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered))
                          return Colors.green;
                        return Colors.blue;
                      },
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  onPressed: _isCVUploaded && _isLettreMotivationUploaded ? _submitForm : null,
                  child: const Text('Envoyer', style: TextStyle(fontSize: 19)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}