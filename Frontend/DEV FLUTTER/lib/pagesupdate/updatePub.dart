import 'package:flutter/material.dart';
import 'package:essai/pagesleleng/notification.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdatePublicationPage extends StatefulWidget {
  final Publication publication;
  UpdatePublicationPage({required this.publication});

  @override
  _UpdatePublicationPageState createState() => _UpdatePublicationPageState();
}

class _UpdatePublicationPageState extends State<UpdatePublicationPage> {
  int? id;
  TextEditingController _titreController = TextEditingController();
  TextEditingController _dateOffreController = TextEditingController();
  TextEditingController _dateExpiration = TextEditingController();

  String _typeOffre = '';
  TextEditingController _competencesController = TextEditingController();
  TextEditingController _telephoneController = TextEditingController();
  String _region = '';
  TextEditingController _descriptionController = TextEditingController();


  final List<String> regions = ['', 'Maritime', 'Plateaux', 'Centrale', 'Kara', 'Savane'];
  final List<String> typesOffre = ['', 'Emploi', 'Stage'];

  @override
  void initState() {
    super.initState();
    id = widget.publication.id;
    _titreController.text = widget.publication.titre;
    _dateOffreController.text = widget.publication.dateOffre;
    _dateExpiration.text = widget.publication.dateExpiration;
    _typeOffre = widget.publication.typeOffre;
    _competencesController.text = widget.publication.competences;
    _region = widget.publication.region;
    _descriptionController.text = widget.publication.description;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (widget.publication.dateOffre != null && widget.publication.dateOffre.isNotEmpty) {
      List<String> dateParts = widget.publication.dateOffre.split('/');
      if (dateParts.length == 3) {
        int day = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[2]);
        initialDate = DateTime(year, month, day);
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOffreController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> updatePublication() async {
    Publication updatedPublication = Publication(
      id: id!,
      titre: _titreController.text,
      dateOffre: _dateOffreController.text,
      typeOffre: _typeOffre,
      competences: _competencesController.text,
      region: _region,
      description: _descriptionController.text,
      statut: widget.publication.statut,
      dateExpiration: widget.publication.dateExpiration,
    );

    final url = 'http://localhost:2003/publications/${updatedPublication.id}/update';

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updatedPublication.toJson()),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Publication mise à jour avec succès avec resoumission"),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Echec de la mise à jour de la publication"),
          duration: Duration(seconds: 5),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mettre à jour publication"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: "Titre"),
                onChanged: (value) {
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date d'offre",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_dateOffreController.text),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date d'expiration",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_dateExpiration.text),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Type d'offre"),
                value: _typeOffre.isNotEmpty ? _typeOffre : widget.publication.typeOffre,
                onChanged: (newValue) {
                  setState(() {
                    _typeOffre = newValue!;
                  });
                },
                items: typesOffre.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _competencesController,
                decoration: const InputDecoration(labelText: "Compétences"),
                onChanged: (value) {
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Région"),
                value: _region.isNotEmpty ? _region : widget.publication.region,
                onChanged: (newValue) {
                  setState(() {
                    _region = newValue!;
                  });
                },
                items: regions.map((region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (value) {
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 35,
                child: ElevatedButton(
                  onPressed: updatePublication,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Mettre à jour"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
