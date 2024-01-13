import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'Infoemployeur.dart';
import 'dart:io';

class InfoEmployeurAdmin extends StatelessWidget {
  final PostulationWithUser data;
  InfoEmployeurAdmin(this.data);

  Future<void> validatePostulation(int id, BuildContext context) async {
    final String url = 'http://localhost:2003/postulations/$id/valider';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande validée avec succès"),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la validation de la demande"),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> rejectPostulationn(int id, BuildContext context) async {
    final String url = 'http://localhost:2003/postulations/$id/rejeter';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande rejetée avec succès"),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors du rejet de la demande"),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _downloadFile(String url, String fileName, BuildContext context) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Directory? downloadsDirectory = await getDownloadsDirectory();

      if (downloadsDirectory != null) {
        String filePath = '${downloadsDirectory.path}/$fileName';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Fichier téléchargé avec succès"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors du téléchargement du fichier : Impossible de récupérer le répertoire de téléchargement"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors du téléchargement du fichier"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  _showConfirmationDialog(BuildContext context, int id, {required bool isValidateAction}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isValidateAction ? 'Validation' : 'Rejet'),
        content: Text(isValidateAction ? 'Voulez-vous valider cette demande ?' : 'Voulez-vous rejeter cette demande ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isValidateAction) {
                validatePostulation(id, context);
              } else {
                rejectPostulationn(id, context);
              }
            },
            child: Text(isValidateAction ? 'Valider' : 'Rejeter'),
          ),
        ],
      ),
    );
  }

  void _downloadCvAndLettreMotivation(BuildContext context, int postulationId) {
    _downloadFile('http://localhost:2003/postulations/$postulationId/cv', 'CV.pdf', context);
    _downloadFile('http://localhost:2003/postulations/$postulationId/lettre-motivation', 'lettreMotivation.pdf', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails sur la postulation'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        //margin: EdgeInsets.only(top: 20, left: 16, right: 18),
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 50,
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child:
                      Text(
                        '${data.user.lastName} ${data.user.firstName}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Numéro du postulant: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.user.phoneNumber,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date postulation: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.postulation.datePostulation,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    const SizedBox(height: 10),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Statut: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.postulation.statut,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:32, vertical: 20), //16
                child: ElevatedButton.icon(
                  onPressed: () {
                    _downloadCvAndLettreMotivation(context, data.postulation.id);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Enrégistrer CV & lettre'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[400],
                    onPrimary: Colors.black,
                  ),
                ),
              ),
              //const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (data.postulation.statut == "Attente")
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog(context, data.postulation.id, isValidateAction: false);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            child: const Text('Rejeter', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 70),
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog(context, data.postulation.id, isValidateAction: true);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent,
                            ),
                            child: const Text('Valider', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 90),
                        ],
                      ),
                  ],

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}