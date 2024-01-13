import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:essai/pagesleleng/notification.dart';

class InformationPage extends StatelessWidget {
  final PublicationWithUser publicationWithUser;

  InformationPage(this.publicationWithUser);

  Future<void> validatePublication(int id, BuildContext context) async {
    final String url = 'http://localhost:2003/publications/$id/validate';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Publication validée avec succès"),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la validation de la publication"),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> rejectPublication(int id, BuildContext context) async {
    final String url = 'http://localhost:2003/publications/$id/reject';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Publication rejetée avec succès"),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors du rejet de la publication"),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, int id, {required bool isValidateAction}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Êtes-vous sûr de vouloir effectuer cette action ?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Fermer la boîte de dialogue
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Couleur de fond du bouton "Annuler"
              ),
              child: const Text("Annuler", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isValidateAction) {
                  validatePublication(id, context);
                } else {
                  rejectPublication(id, context);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: isValidateAction ? Colors.green : Colors.red,
              ),
              child: Text(isValidateAction ? "Valider" : "Rejeter", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final Publication publication = publicationWithUser.publication;
    final User user = publicationWithUser.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails sur l'offre"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            elevation: 50, // Ajoute une élévation pour donner une ombre au Card
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      publication.titre,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(), // Séparateur
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date d\'offre:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        publication.dateOffre,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Type d\'offre:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        publication.typeOffre,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Région:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        publication.region,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(), // Séparateur
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nom de l\'offrant:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${user.lastName} ${user.firstName}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Numéro de l\'offrant:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.phoneNumber,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text(
                    'Compétences requises',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    publication.competences,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const Text(
                    'Description poste',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    publication.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(context, publication.id, isValidateAction: false);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('Rejeter', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                      const SizedBox(width: 50),
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(context, publication.id, isValidateAction: true);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('Valider', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
