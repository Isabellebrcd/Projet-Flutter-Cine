import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'characters_details.dart';
import 'main.dart';

class DetailsComicsPage extends StatefulWidget {
  static const String apiKey = '9f0bb9bce7f9154f43645e7d6cb131a10fe20346';

  final String url_volume;
  final String url_issue;
  final String comicsName;
  final String imageUrl;
  final String volumeName;
  final String comicNumber;
  final String coverDate;

  DetailsComicsPage({
    required this.url_volume,
    required this.url_issue,
    required this.comicsName,
    required this.imageUrl,
    required this.volumeName,
    required this.comicNumber,
    required this.coverDate,
  });

  @override
  _DetailsComicsPageState createState() => _DetailsComicsPageState();
}

class _DetailsComicsPageState extends State<DetailsComicsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? description;
  bool persosDataLoaded = false;
  bool autorsDataLoaded = false;
  List<Map<String, dynamic>> persosData = [];
  List<Map<String, dynamic>> autorsData = [];
  List<Map<String, dynamic>> creatorsData = [];
  List<Map<String, dynamic>> publishersData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchDescription();
    getAutorsData();
    getPersosData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchDescription() async {
    try {
      final response = await http.get(Uri.parse(widget.url_volume +
          "?api_key=${DetailsComicsPage.apiKey}&format=json"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        //final desc = jsonData['results']['description'];

        String desc = jsonData['results']['description'] ?? 'Unknown';

        setState(() {
          description = desc;
        });
      } else {
        print('Erreur de requête: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la description: $e');
    }
  }

  Future<void> getPersosData() async {
    final response = await http.get(Uri.parse(
        widget.url_issue + "?api_key=${DetailsComicsPage.apiKey}&format=json"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> persos = data['results']['character_credits'];
      int count = 0; // Counter to track the number of characters collected

      for (var perso in persos) {
        if (count >= 5)
          break; // Break the loop if 5 characters are already collected

        String persoDetailUrl = perso['api_detail_url'];
        // Effectuer une nouvelle requête pour obtenir les détails complets du personnage
        final persoDetailResponse = await http.get(Uri.parse(
            '$persoDetailUrl?api_key=${DetailsComicsPage.apiKey}&format=json'));

        if (persoDetailResponse.statusCode == 200) {
          Map<String, dynamic> persoData =
          json.decode(persoDetailResponse.body);
          String imageUrl = persoData['results']['image']['original_url'];
          // Mettre à jour le modèle de données pour inclure l'URL de l'image

          String Histoire = persoData['results']['description'] ?? 'Unknown';
          String realName = persoData['results']['real_name'] ?? 'Unknown';
          String alias = persoData['results']['aliases'] ?? 'Unknown';

          int  genre = persoData['results']['gender'];
          String birth = persoData['results']['birth'] ?? 'Inconnue';
          String death = persoData['results']['death'] ?? 'N/A';

          Map<String, dynamic> publisherMap = persoData['results']['publisher'] ?? {'name': 'Unknown'};
          publishersData.add({
            'name': publisherMap['name'],
          });

          List<dynamic> creators = persoData['results']['creators'] ?? 'Unknown';
          for (var creator in creators) {
            creatorsData.add({
              'name': creator['name'],
            });
          }

          persosData.add({
            'name': perso['name'],
            'api_detail_url': persoDetailUrl,
            'image_url': imageUrl,
            'description': Histoire,
            'realName' : realName,
            'alias' : alias,
            'genre': genre,
            'birth':birth,
            'death':death,
          });
          persosDataLoaded = true;

          count++; // Increment the count after adding a character's data
        } else {
          throw Exception('Failed to load character details');
        }
      }
      setState(() {
        persosData;
        creatorsData;
        publishersData;
      });
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Future<void> getAutorsData() async {
    final response = await http.get(Uri.parse(
        widget.url_issue + "?api_key=${DetailsComicsPage.apiKey}&format=json"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> autors = data['results']['person_credits'];
      int count = 0; // Counter to track the number of characters collected

      for (var autor in autors) {
        if (count >= 5)
          break; // Break the loop if 5 characters are already collected

        String autorDetailUrl = autor['api_detail_url'];
        // Effectuer une nouvelle requête pour obtenir les détails complets du personnage
        final autorDetailResponse = await http.get(Uri.parse(
            '$autorDetailUrl?api_key=${DetailsComicsPage.apiKey}&format=json'));

        if (autorDetailResponse.statusCode == 200) {
          Map<String, dynamic> autorData =
          json.decode(autorDetailResponse.body);
          String imageUrl = autorData['results']['image']['original_url'];
          // Mettre à jour le modèle de données pour inclure l'URL de l'image
          autorsData.add({
            'name': autor['name'],
            'api_detail_url': autorDetailUrl,
            'image_url': imageUrl,
            'role': autor['role'],
          });
          autorsDataLoaded = true;

          count++; // Increment the count after adding a character's data
        } else {
          throw Exception('Failed to load character details');
        }
      }
      setState(() {
        autorsData;
      });
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.volumeName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1),
                  BlendMode.dstATop,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 90),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            widget.imageUrl,
                            width: 95,
                            height: 127,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  '${widget.comicsName}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'res/svg/ic_books_bicolor.svg',
                                width: 17,
                                height: 15,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                                height: 15,
                              ),
                              Text(
                                'N°${widget.comicNumber}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'res/svg/ic_calendar_bicolor.svg',
                                width: 16,
                                height: 15,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                                height: 15,
                              ),
                              Text(
                                '${widget.coverDate}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TabBar(
                  dividerColor: Colors.transparent,
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Histoire'),
                    Tab(text: 'Auteurs'),
                    Tab(text: 'Personnages'),
                  ],
                  splashFactory: NoSplash.splashFactory,
                  labelColor: Colors.white,
                  labelStyle: TextStyle(fontSize: 16),
                  unselectedLabelStyle: TextStyle(fontSize: 16),
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  indicatorColor: AppColors.orange,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(27.0),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCards,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          child: description != null
                              ? Text(
                            '${extractDescription(description!)}',
                            style: TextStyle(
                                color: Colors.white, fontSize: 17),
                          )
                              : Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        autorsDataLoaded
                            ? AutorsTab(autorsData: autorsData)
                            : Text('Unknown',
                            style: TextStyle(
                                color: Colors.white, fontSize: 17)),
                        // Affiche "unknown" si les données des auteurs ne sont pas disponibles
                        persosDataLoaded
                            ? PersosTab(persosData: persosData,
                            creatorsData : creatorsData,
                            publishersData : publishersData)
                            : Text('Unknown',
                            style: TextStyle(
                                color: Colors.white, fontSize: 17)),
                        // Affiche "unknown" si les données des personnages ne sont pas disponibles
                        // Ajoutez d'autres onglets ou des widgets de remplacement pour d'autres onglets
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String extractDescription(String htmlDescription) {
  final document = parse(htmlDescription);
  final paragraphs = document.querySelectorAll('p');
  final List<String> descriptions =
  paragraphs.map((element) => element.text).toList();
  return descriptions.join('\n');
}

class AutorsTab extends StatelessWidget {
  final List<Map<String, dynamic>> autorsData;

  AutorsTab({required this.autorsData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var autor in autorsData)
            Padding(
              padding: const EdgeInsets.only(bottom: 15, right: 18),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.network(
                      autor['image_url'],
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 18),
                  SizedBox(
                    width: 250, // Définir la largeur du conteneur
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${autor['name']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        // Ajout d'un espacement vertical entre le nom et le rôle
                        Text(
                          '${autor['role']}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap:
                          true, // Permet au texte de se découper sur plusieurs lignes si nécessaire
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PersosTab extends StatelessWidget {
  final List<Map<String, dynamic>> persosData;
  final List<Map<String, dynamic>> creatorsData;
  final List<Map<String, dynamic>> publishersData;

  PersosTab({required this.persosData,
    required this.creatorsData,
    required this.publishersData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var perso in persosData)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterDetailsPage(
                      characterName: perso['name'],
                      imageUrl: perso['image_url'],
                      Histoire: perso['description'],
                      nomHeros: perso['name'],
                      nomReel: perso['realName'],
                      alias: perso['alias'],
                      publishersData : publishersData,
                      creatorsData: creatorsData,
                      genre: perso['genre'],
                      dateNaissance: perso['birth'],
                      dateDeces: perso['death'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15, right: 18),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.network(
                        perso['image_url'],
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 18),
                    SizedBox(
                      width: 250, // Définir la largeur du conteneur
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${perso['name']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          // Ajout d'un espacement vertical entre le nom et le rôle
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
