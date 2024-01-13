import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:essai/pagesinfo/Infoacceuil.dart';

class Publication {
  final int id;
  final String titre;
  final String dateOffre;
  final String typeOffre;
  final String competences;
  final String region;
  final String description;
  final String dateExpiration;

  Publication({
    required this.id,
    required this.titre,
    required this.dateOffre,
    required this.typeOffre,
    required this.competences,
    required this.region,
    required this.description,
    required this.dateExpiration,
  });
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

class PublicationWithUser {
  final Publication publication;
  final User user;

  PublicationWithUser({
    required this.publication,
    required this.user,
  });
}

class AcceuilPage extends StatefulWidget {
  @override
  _AcceuilPageState createState() => _AcceuilPageState();
}

class _AcceuilPageState extends State<AcceuilPage> {
  bool _searchCompleted = false;
  bool _isSearchBarVisible = false;
  TextEditingController _searchController = TextEditingController();
  List<PublicationWithUser> _searchResults = [];
  late AnimationController _controller;


  Future<List<PublicationWithUser>> fetchPublicationsWithUsers() async {
    final response = await http.get(Uri.parse('http://localhost:2003/publications/accepted-publications'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<PublicationWithUser> publicationsWithUsers = jsonData.map((data) {
        Publication publication = Publication(
          id: data['publication']['id'],
          titre: data['publication']['titre'],
          dateOffre: data['publication']['dateOffre'],
          typeOffre: data['publication']['typeOffre'],
          competences: data['publication']['competences'],
          region: data['publication']['region'],
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

      return publicationsWithUsers;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  Future<void> refreshData() async {
    setState(() {});
  }

  Future<List<PublicationWithUser>> _searchPublications(String searchTerm) async {
    final response = await http.get(
      Uri.parse('http://localhost:2003/publications/search?searchTerm=$searchTerm'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<PublicationWithUser> publicationsWithUsers = [];

      for (var data in jsonData) {
        if (data['publication'] != null && data['user'] != null) {
          Publication publication = Publication(
            id: data['publication']['id'] ?? '',
            titre: data['publication']['titre'] ?? '',
            dateOffre: data['publication']['dateOffre'] ?? '',
            typeOffre: data['publication']['typeOffre'] ?? '',
            competences: data['publication']['competences'] ?? [],
            region: data['publication']['region'] ?? '',
            description: data['publication']['description'] ?? '',
            dateExpiration: data['publication']['dateExpiration'] ?? '',
          );

          User user = User(
            id: data['user']['id'] ?? '',
            firstName: data['user']['firstName'] ?? '',
            lastName: data['user']['lastName'] ?? '',
            email: data['user']['email'] ?? '',
            phoneNumber: data['user']['phoneNumber'] ?? '',
          );

          publicationsWithUsers.add(PublicationWithUser(publication: publication, user: user));
        }
      }

      if (publicationsWithUsers.isEmpty) {
        print("Aucune réponse.");
      }

      return publicationsWithUsers;
    } else {
      throw Exception('Echec de chargement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(_isSearchBarVisible ? 'Page de recherche' : 'Accueil'),
        leading: _isSearchBarVisible
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            setState(() {
              _isSearchBarVisible = false;
            });
          },
        )
            : null,
        actions: _isSearchBarVisible
            ? null
            : [
          IconButton(
            icon: const Icon(Icons.content_paste_search_outlined),
            onPressed: () {
              setState(() {
                _isSearchBarVisible = true;
              });
            },
          ),
        ],
      ),

      //Ici

      body: RefreshIndicator(
        onRefresh: refreshData,
        child: FutureBuilder<List<PublicationWithUser>>(
          future: fetchPublicationsWithUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (_isSearchBarVisible) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Taper ici pour trouver une publication',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        TextButton(
                          onPressed: () async {
                            String searchText = _searchController.text.trim();
                            if (searchText.isNotEmpty) {
                              List<PublicationWithUser> results = await _searchPublications(searchText);
                              setState(() {
                                _searchCompleted = true;
                                _searchResults = results;
                              });
                            }
                          },
                          child: const Text(
                            'Rechercher',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        PublicationWithUser publicationWithUser = _searchResults[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InformationDetailPage(publicationWithUser)),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  publicationWithUser.publication.titre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text('Type d\'offre: ${publicationWithUser.publication.typeOffre}'),
                                const SizedBox(height: 10),
                                Text('Date d\'offre: ${publicationWithUser.publication.dateOffre}'),
                                const SizedBox(height: 10),
                                Text('Date d\'expiration: ${publicationWithUser.publication.dateExpiration}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Publié par: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      publicationWithUser.user.firstName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ), //ici
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_searchCompleted && _searchResults.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.redAccent,
                            ),
                            SizedBox(height:10),
                            Text(
                              "Aucune réponse trouvée.",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
            else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<PublicationWithUser> publicationsWithUsers = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Offres Disponibles',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: publicationsWithUsers.length,
                      itemBuilder: (context, index) {
                        PublicationWithUser publicationWithUser = publicationsWithUsers[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InformationDetailPage(publicationWithUser)),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  publicationWithUser.publication.titre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text('Type d\'offre: ${publicationWithUser.publication.typeOffre}'),
                                const SizedBox(height: 10),
                                Text('Date d\'offre: ${publicationWithUser.publication.dateOffre}'),
                                const SizedBox(height: 10),
                                Text('Date d\'expiration: ${publicationWithUser.publication.dateExpiration}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Publié par: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${publicationWithUser.user.firstName}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text('Aucune publication disponible'),
              );
            }
          },
        ),
      ),

      //ici

    );
  }
}