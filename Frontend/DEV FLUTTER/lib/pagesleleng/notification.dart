import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login.dart';
import 'package:essai/pagesinfo/Infoadmin.dart';
import 'package:essai/pagesinfo/Infoemployeur.dart';
import 'package:essai/pagesinfo/Infodemandeur.dart';
import 'package:essai/pagesinfo/Demandeurinfo.dart';
import 'package:essai/pub_post/pubStageEmploi.dart';


class Publication {
  final int id;
  final String titre;
  final String dateOffre;
  final String typeOffre;
  final String competences;
  final String statut;
  final String region;
  final String description;
  final String dateExpiration;

  Publication({
    required this.id,
    required this.titre,
    required this.dateOffre,
    required this.typeOffre,
    required this.competences,
    required this.statut,
    required this.region,
    required this.description,
    required this.dateExpiration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'dateOffre': dateOffre,
      'typeOffre': typeOffre,
      'competences': competences,
      'region': region,
      'description': description,
      'statut': statut,
      'dateExpiration': dateExpiration,
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

class PostulationWithPublicationWithUser {
  final Postulation postulation;
  final Publication publication;
  final User user;

  PostulationWithPublicationWithUser({
    required this.postulation,
    required this.publication,
    required this.user,
  });
}

class Demande{
  final int id;
  final String typeDemande;
  final String domaine;
  final String region;
  final String dateDemande;
  final String statut;
  final String presentation;

  Demande({
    required this.id,
    required this.typeDemande,
    required this.domaine,
    required this.region,
    required this.dateDemande,
    required this.statut,
    required this.presentation,

  });
}

class DemandeWithUser {
  final Demande demande;
  final User user;

  DemandeWithUser({
    required this.demande,
    required this.user,
  });
}

class PublicationWithUser {
  final Publication publication;
  final User user;

  PublicationWithUser({
    required this.publication,
    required this.user,
  });
}

class PostulationWithPublication {
  final Postulation postulation;
  final Publication publication;

  PostulationWithPublication({
    required this.postulation,
    required this.publication,
  });
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int? _userID;
  String? _userProfile;
  bool _isUserLoggedIn = false;
  bool _isLoading = true;

  Future<void> refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await _getUserDataFromLocalStorage();
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<PublicationWithUser>> fetchPublications() async {
    final response =
    await http.get(Uri.parse('http://localhost:2003/publications/Attente'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<PublicationWithUser> publicationWithUser = jsonData.map((data) {

        Publication publication = Publication(
          id: data['publication']['id'],
          titre: data['publication']['titre'],
          dateOffre: data['publication']['dateOffre'],
          typeOffre: data['publication']['typeOffre'],
          competences: data['publication']['competences'],
          region: data['publication']['region'],
          statut: data['publication']['statut'],
          description: data['publication']['description'],
          dateExpiration: data['publication']['dateExpiration'],
        );

        User user = User(
          id: data['user']['id'],
          firstName: data['user']['firstName'],
          lastName: data['user']['lastName'],
          email: data['user']['email'],
          phoneNumber: data['user']['phoneNumber'],

        );
        return PublicationWithUser(publication: publication, user: user);
      }).toList();
      return publicationWithUser;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  Future<List<Publication>> fetchPublicationsByUserId() async {
    final response =
    await http.get(Uri.parse('http://localhost:2003/publications/$_userID/accepted-or-rejected'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Publication> publications = jsonData.map((data) => Publication(
        id: data['id'],
        titre: data['titre'],
        dateOffre: data['dateOffre'],
        typeOffre: data['typeOffre'],
        competences: data['competences'],
        statut: data['statut'],
        region: data['region'],
        description: data['description'],
        dateExpiration: data['dateExpiration'],
      )).toList();

      return publications;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  Future<List< PostulationWithPublicationWithUser>> fetchPostulationsByUserId() async {
    final response = await http.get(Uri.parse('http://localhost:2003/postulations/employer/$_userID/all-postulations'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<PostulationWithPublicationWithUser> postulationWithPublicationWithUser = jsonData.map((data) {
        Postulation postulation = Postulation(
          id: data['postulation']['id'],
          datePostulation: data['postulation']['datePostulation'],
          statut: data['postulation']['statut'],
        );

        Publication publication = Publication(
          id: data['publication']['id'],
          titre: data['publication']['titre'],
          dateOffre: data['publication']['dateOffre'],
          typeOffre: data['publication']['typeOffre'],
          competences: data['publication']['competences'],
          region: data['publication']['region'],
          statut: data['publication']['statut'],
          description: data['publication']['description'],
          dateExpiration: data['publication']['dateExpiration'],
        );

        User user = User(
          id: data['user']['id'],
          firstName: data['user']['firstName'],
          lastName: data['user']['lastName'],
          email: data['user']['email'],
          phoneNumber: data['user']['phoneNumber'],

        );
        return PostulationWithPublicationWithUser(postulation: postulation, publication: publication, user: user);

      }).toList();

      return postulationWithPublicationWithUser;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  Future<List<PostulationWithPublication>> fetchPostulationsWithPublications() async {
    final response = await http.get(Uri.parse('http://localhost:2003/postulations/users/$_userID/postulations'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<PostulationWithPublication> postulations = jsonData.map((data) {
        return PostulationWithPublication(
          postulation: Postulation(
            id: data['postulation']['id'],
            datePostulation: data['postulation']['datePostulation'],
            statut: data['postulation']['statut'],
          ),

          publication: Publication(
            id: data['publication']['id'],
            titre: data['publication']['titre'],
            dateOffre: data['publication']['dateOffre'],
            typeOffre: data['publication']['typeOffre'],
            competences: data['publication']['competences'],
            statut: data['publication']['statut'],
            region: data['publication']['region'],
            description: data['publication']['description'],
            dateExpiration: data['publication']['dateExpiration'],
          ),
        );
      }).toList();

      return postulations;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  Future<List<Demande>> fetchDemandesByUserId() async {
    final response =
    await http.get(Uri.parse('http://localhost:2003/demandes/user/$_userID/user'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Demande> demandes = jsonData.map((data) => Demande(
        id: data['id'],
        domaine: data['domaine'],
        dateDemande: data['dateDemande'],
        region: data['region'],
        statut: data['statut'],
        typeDemande: data['typeDemande'],
        presentation: data['presentation'],
      )).toList();

      return demandes;
    } else {
      throw Exception('Echec de chargement');
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
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Center(
          child: _isLoading ? _buildLoadingWidget() : _buildNotificationWidget(),
        ),
      ),
      floatingActionButton: _isUserLoggedIn && (_userProfile == "Employeur")
          ? FloatingActionButton(
        onPressed: () {
          if (_isUserLoggedIn && _userProfile == "Employeur") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PubStageEmploi()),
            );
          }
        },
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildLoadingWidget() {
    return const CircularProgressIndicator();
  }

  Widget _buildNotificationWidget() {
    if (_isUserLoggedIn) {

      if (_userProfile == "Administrateur") {
        return FutureBuilder<List<PublicationWithUser>>(
          future: fetchPublications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return _buildErrorMessage('Erreur de chargement');
            } else {
              List<PublicationWithUser> publicationWithUsers = snapshot.data ?? [];
              if (publicationWithUsers.isEmpty) {
                return const Center(
                  child: Text('Aucune offre en cours'),
                );
              } else {
                return ListView.builder(
                  itemCount: publicationWithUsers.length,
                  itemBuilder: (context, index) {
                    PublicationWithUser publicationWithUser = publicationWithUsers[index];
                    Publication publication = publicationWithUser.publication;
                    User user = publicationWithUser.user;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          'Titre de l\'offre: ${publication.titre}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text('Date d\'offre: ${publication.dateOffre}',
                            style: const TextStyle(
                              color: Colors.redAccent
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Nom de l\'offrant: ${user.lastName}'),
                          ],
                        ),
                        trailing: Icon(
                          getIconForType(publication.typeOffre),
                          color: Colors.blue,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InformationPage(publicationWithUser),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            }
          },
        );
      }

      else if (_userProfile == "Employeur") {
        return RefreshIndicator(
          onRefresh: refreshData,
          child: FutureBuilder<List<Publication>>(
            future: fetchPublicationsByUserId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              } else if (snapshot.hasError) {
                return _buildErrorMessage('Erreur de chargement');
              } else {
                List<Publication> publications = snapshot.data ?? [];

                if (publications.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Text(
                      'Aucune offre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: publications.length,
                        itemBuilder: (context, index) {
                          Publication publication = publications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                publication.titre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    'Date d\'offre: ${publication.dateOffre}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        getIconForStatut(publication.statut),
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        publication.statut,
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
                                    builder: (context) => Information(publication),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              }
            },
          ),
        );
      }

      if (_userProfile == "Demandeur") {
        return DefaultTabController(
          length: 2, // Nombre d'onglets
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Postulations',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Demandes',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await refreshData();
                      },
                      child: FutureBuilder<List<PostulationWithPublication>>(
                        future: fetchPostulationsWithPublications(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingWidget();
                          } else if (snapshot.hasError) {
                            return _buildErrorMessage('Erreur de chargement');
                          } else {
                            List<PostulationWithPublication> postulations = snapshot.data ?? [];
                            if (postulations.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Aucune candidature en cours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: postulations.length,
                                itemBuilder: (context, index) {
                                  PostulationWithPublication postulationWithPublication = postulations[index];
                                  Postulation postulation = postulationWithPublication.postulation;
                                  Publication publication = postulationWithPublication.publication;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      title: Text(
                                        'Titre de l\'offre: ${ publication.titre}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Text('Date postulation: ${postulation.datePostulation}',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                getIconForStatut(postulation.statut),
                                                color: Colors.blue,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                postulation.statut,
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
                                            builder: (context) => InfoDemandeur(postulationWithPublication),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: () async {
                        await refreshData();
                      },
                      child: FutureBuilder<List<Demande>>(
                        future: fetchDemandesByUserId(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingWidget();
                          } else if (snapshot.hasError) {
                            return _buildErrorMessage('Erreur de chargement');
                          } else {
                            List<Demande> demandes = snapshot.data ?? [];
                            if (demandes.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Aucune demande en cours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: demandes.length,
                                itemBuilder: (context, index) {
                                  Demande demande = demandes[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      title: Text(
                                        'Type de demande: ${demande.typeDemande}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Text(
                                            'Date demande: ${demande.dateDemande}',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                getIconForStatut(demande.statut),
                                                color: Colors.blue,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                demande.statut,
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
                                            builder: (context) => DemandeurInfoPage(demandes: [demande],),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      else {
        return _buildErrorMessage('Profil inconnu');
      }

    }

    else {
     return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Vous n\'êtes pas connecté!',
            style: TextStyle(fontSize: 18, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14), //vertical 12
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      );
    }
  }

  IconData getIconForType(String type) {
    if (type == 'Emploi') {
      return Icons.work;
    } else if (type == 'Stage') {
      return Icons.work_outline;
    } else {
      return Icons.info;
    }
  }

  IconData getIconForStatut(String statut) {
    if (statut == 'Accepter') {
      return Icons.verified;
    } else if (statut == 'Rejeter') {
      return Icons.not_interested_sharp;
      //return Icons.cancel_outlined;
    } else {
      return Icons.info;
    }
  }

  Widget _buildErrorMessage(String message) {
    return Text(
      message,
      style: const TextStyle(fontSize: 24, color: Colors.red),
    );
  }

}
