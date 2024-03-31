import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:test_api2/main.dart';
import 'package:intl/intl.dart';

import 'characters_details.dart';


class DetailsPage extends StatefulWidget {
  static const String apiKey = '1159b9ddc377bf342b90fe1100fd57522cde7a5f';

  final String seriesName;
  final String imageUrl;
  final String publisher;
  final String episodeCount;
  final String startYear;
  final String url;
  final String histoire;

  DetailsPage({
    required this.seriesName,
    required this.imageUrl,
    required this.publisher,
    required this.episodeCount,
    required this.startYear,
    required this.url,
    required this.histoire,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool charactersDataLoaded = false;
  bool episodesDataLoaded = false;
  List<Map<String, dynamic>> charactersData = [];
  List<Map<String, dynamic>> episodesData = [];
  List<Map<String, dynamic>> creatorsData = [];
  List<Map<String, dynamic>> publishersData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getCharactersData();
    getEpisodesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getCharactersData() async {
    final response = await http.get(
        Uri.parse(widget.url + "?api_key=${DetailsPage.apiKey}&format=json"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> characters = data['results']['characters'];
      int count = 0; // Counter to track the number of characters collected

      for (var character in characters) {
        if (count >= 5)
          break; // Break the loop if 5 characters are already collected

        String characterDetailUrl = character['api_detail_url'];
        // Effectuer une nouvelle requête pour obtenir les détails complets du personnage
        final characterDetailResponse = await http.get(Uri.parse(
            '$characterDetailUrl?api_key=${DetailsPage.apiKey}&format=json'));

        if (characterDetailResponse.statusCode == 200) {
          Map<String, dynamic> characterData =
          json.decode(characterDetailResponse.body);
          String imageUrl = characterData['results']['image']['original_url'];

          String Histoire= characterData['results']['description'] ?? 'Unknown';
          String realName = characterData['results']['real_name'] ?? 'Unknown';
          String alias = characterData['results']['aliases'] ?? 'Unknown';
          int genre = characterData['results']['gender'];
          String birth = characterData['results']['birth'] ?? 'Inconnue';
          String death = characterData['results']['death'] ?? 'N/A';

          Map<String, dynamic> publisherMap = characterData['results']['publisher'] ?? {'name': 'Unknown'};
          publishersData.add({
            'name': publisherMap['name'],
          });

          List<dynamic> creators = characterData['results']['creators'] ?? 'Unknown';
          for (var creator in creators) {
            creatorsData.add({
              'name': creator['name'],
            });
          }

          charactersData.add({
            'name': character['name'],
            'api_detail_url': characterDetailUrl,
            'image_url': imageUrl,
            'description':Histoire,
            'realName' : realName,
            'alias' : alias,
            'genre': genre,
            'birth':birth,
            'death':death,
          });
          charactersDataLoaded = true;

          count++; // Increment the count after adding a character's data
        } else {
          throw Exception('Failed to load character details');
        }
      }
      setState(() {
        charactersData;
        creatorsData;
        publishersData;
      });
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Map<String, String> months = {
    "01": "Janvier",
    "02": "Février",
    "03": "Mars",
    "04": "Avril",
    "05": "Mai",
    "06": "Juin",
    "07": "Juillet",
    "08": "Août",
    "09": "Septembre",
    "10": "Octobre",
    "11": "Novembre",
    "12": "Décembre",
  };

  Future<void> getEpisodesData() async {
    final response = await http.get(
        Uri.parse(widget.url + "?api_key=${DetailsPage.apiKey}&format=json"));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> episodes = data['results']['episodes'];
      int count2 = 0; // Counter to track the number of characters collected
      for (var episode in episodes) {
        if (count2 >= 5)
          break; // Break the loop if 5 characters are already collected
        String episodeDetailUrl = episode['api_detail_url'];

        // Effectuer une nouvelle requête pour obtenir les détails complets du personnage
        final episodeDetailResponse = await http.get(Uri.parse(
            '$episodeDetailUrl?api_key=${DetailsPage.apiKey}&format=json'));

        if (episodeDetailResponse.statusCode == 200) {
          Map<String, dynamic> episodeData =
          json.decode(episodeDetailResponse.body);
          String imageUrl = episodeData['results']['image']['original_url'];
          String date = episodeData['results']['date_added'];
          DateTime dateTime = DateTime.parse(date);
          String formattedYear = DateFormat(' yyyy').format(dateTime);
          String formattedMonth = DateFormat('MM').format(dateTime);
          String formattedDay = DateFormat('dd ').format(dateTime);
          // Mettre à jour le modèle de données pour inclure l'URL de l'image
          episodesData.add({
            'name': episode['name'],
            'episode_number': episode['episode_number'],
            'api_detail_url': episodeDetailUrl,
            'image_url': imageUrl,
            'date_added':
            formattedDay + months[formattedMonth]! + formattedYear,
          });
          episodesDataLoaded = true;
          count2++; // Increment the count after adding a character's data
        } else {
          throw Exception('Failed to load episode details');
        }
      }
      setState(() {
        episodesData;
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
          widget.seriesName,
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
                                SvgPicture.asset(
                                  'res/svg/ic_publisher_bicolor.svg',
                                  width: 17,
                                  height: 13,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                  height: 15,
                                ),
                                Text(
                                  '${widget.publisher}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'res/svg/ic_tv_bicolor.svg',
                                width: 17,
                                height: 15,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                                height: 15,
                              ),
                              Text(
                                '${widget.episodeCount} épisodes',
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
                                '${widget.startYear}',
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
                    Tab(text: 'Personnages'),
                    Tab(text: 'Episodes'),
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
                        DescriptionTab(histoire: widget.histoire),
                        charactersDataLoaded
                            ? CharactersTab(charactersData: charactersData,
                            creatorsData : creatorsData,
                            publishersData : publishersData)
                            : Center(child: CircularProgressIndicator()),
                        episodesDataLoaded
                            ? EpisodesTab(episodesData: episodesData)
                            : Center(child: CircularProgressIndicator()),
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

class DescriptionTab extends StatelessWidget {
  final String histoire;

  DescriptionTab({required this.histoire});

  String extractDescription(String htmlDescription) {
    final document = parse(htmlDescription);
    final paragraphs = document.querySelectorAll('p');
    final List<String> descriptions =
    paragraphs.map((element) => element.text).toList();
    return descriptions.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Text(
              '${extractDescription(histoire)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CharactersTab extends StatelessWidget {
  final List<Map<String, dynamic>> charactersData;
  final List<Map<String, dynamic>> creatorsData;
  final List<Map<String, dynamic>> publishersData;

  CharactersTab({required this.charactersData,
    required this.creatorsData,
    required this.publishersData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var character in charactersData)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterDetailsPage(
                      characterName: character['name'],
                      imageUrl: character['image_url'],
                      Histoire: character['description'],
                      nomHeros: character['name'],
                      nomReel: character['realName'],
                      alias: character['alias'],
                      publishersData : publishersData,
                      creatorsData: creatorsData,
                      genre: character['genre'],
                      dateNaissance: character['birth'],
                      dateDeces: character['death'],
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
                        character['image_url'],
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 18),
                    Text(
                      '${character['name']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
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


class EpisodesTab extends StatelessWidget {
  final List<Map<String, dynamic>> episodesData;

  EpisodesTab({required this.episodesData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var episode in episodesData)
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundElementCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          episode['image_url'],
                          width: 126,
                          height: 105,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Episode #${episode['episode_number']}',
                            style: TextStyle(
                              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: 165,
                            child: Text(
                              '${episode['name']}',
                              style: TextStyle(
                                color: Colors.white,fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400,
                              ),
                              softWrap: true,
                            ),
                          ),
                          SizedBox(height: 17),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'res/svg/ic_calendar_bicolor.svg',
                                width: 14,
                                height: 13,
                                color: AppColors.textBottomBar,
                              ),
                              SizedBox(width: 7,),
                              Text(
                                '${episode['date_added']}',
                                style: TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
