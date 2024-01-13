import 'package:flutter/material.dart';
import 'package:essai/pagesleleng/notification.dart';
import 'package:http/http.dart' as http;
import 'package:essai/pagesupdate/updatePub.dart';
import 'dart:convert';
import 'Infoemployeuradmin.dart';


class Postulation {
  final int id;
  final String datePostulation;
  final String statut;

  Postulation({
    required this.id,
    required this.datePostulation,
    required this.statut,

  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datePostulation': datePostulation,
      'statut': statut,
    };
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });
}

class PostulationWithUser {
  final Postulation postulation;
  final User user;

  PostulationWithUser({
    required this.postulation,
    required this.user,
  });
}


class Information extends StatefulWidget {
  final Publication publication;
  Information(this.publication);


  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  bool _isLoading = false;
  String searchQuery = '';
  List<PostulationWithUser> postulationsWithUsers = [];

  Future<List<PostulationWithUser>> fetchPostulationsByPublicationId(int id) async {
    final response = await http.get(Uri.parse('http://localhost:2003/postulations/publication/$id'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<PostulationWithUser> postulationWithUser = jsonData.map((data) {
        Postulation postulation = Postulation(
          id: data['postulation']['id'],
          datePostulation: data['postulation']['datePostulation'],
          statut: data['postulation']['statut'],
        );

        User user = User(
          id: data['user']['id'],
          firstName: data['user']['firstName'],
          lastName: data['user']['lastName'],
          email: data['user']['email'],
          phoneNumber: data['user']['phoneNumber'],
        );
        return PostulationWithUser(postulation: postulation, user: user);
      }).toList();

      return postulationWithUser;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  Future<void> refreshData() async {
    try {
      List<PostulationWithUser> refreshedData = await fetchPostulationsByPublicationId(widget.publication.id);
      setState(() {
        postulationsWithUsers = refreshedData;
      });
    } catch (error) {
      print('Erreur lors du rafraîchissement des données : $error');
    }
  }

  Future<void> deletePublication(int id, BuildContext context) async {
    final url = 'http://localhost:2003/publications/$id/delete';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Publication supprimée avec succès"),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la suppression de la publication"),
        ),
      );
    }
  }

  void showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Information"),
          content: const Text("Voulez-vous vraiment supprimer cette publication ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deletePublication(id, context);
              },
              child: const Text(
                "Oui",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int id = widget.publication.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails sur la publication"),
        backgroundColor: Colors.green,
        /*actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              refreshData();
            },
          ),
        ],*/
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                Card(
                  elevation: 50, // Ajoute une élévation pour donner une ombre au Card
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            widget.publication.titre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
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
                              widget.publication.dateOffre,
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
                              'Date d\'expiration:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.publication.dateExpiration,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
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
                              widget.publication.typeOffre,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Region:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.publication.region,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                          widget.publication.competences,
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
                          widget.publication.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Statut:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.publication.statut,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              showDeleteConfirmation(context, id);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // New 777
                FutureBuilder<List<PostulationWithUser>>(
                  future: fetchPostulationsByPublicationId(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Erreur de chargement des postulations');
                    } else {
                      List<PostulationWithUser> postulationsWithUsers = snapshot.data ?? [];
                      int nombrePostulants = postulationsWithUsers.length;

                      if (nombrePostulants > 0) {
                        return Column(
                          children: [
                            Text('Nombre de postulants : $nombrePostulants'),
                            Card(
                              margin: const EdgeInsets.all(16),
                              child: Column(
                                children: postulationsWithUsers.map((postulationWithUser) {
                                  return ListTile(
                                    title: Text(
                                      '${postulationWithUser.postulation.datePostulation}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Text('Nom du postulant: ${postulationWithUser.user.lastName}'),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              getIconForStatut(postulationWithUser.postulation.statut),
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              postulationWithUser.postulation.statut,
                                              style: const TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InfoEmployeurAdmin(postulationWithUser),
                                        ),
                                      );
                                    },

                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Text('Aucun postulant');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData getIconForStatut(String statut) {
    if (statut == 'Accepter') {
      return Icons.verified;
    } else if (statut == 'Rejeter') {
      return Icons.not_interested_sharp;
    } else {
      return Icons.info;
    }
  }
}