import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'main.dart';
import 'characters_details.dart';

class DetailsMoviesPage extends StatefulWidget {
  static const String apiKey = '9f0bb9bce7f9154f43645e7d6cb131a10fe20346';
  final String moviesName;
  final String imageUrl;
  final String runtimeMovies;
  final String addedData;
  final String synopsis;
  final String url;

  DetailsMoviesPage({
    required this.moviesName,
    required this.imageUrl,
    required this.runtimeMovies,
    required this.addedData,
    required this.synopsis,
    required this.url,
  });

  @override
  _DetailsMoviesPageState createState() => _DetailsMoviesPageState();
}

class _DetailsMoviesPageState extends State<DetailsMoviesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? budget;
  String? box_revenue;
  String? tot_revenue;
  String? rating;
  bool charactersDataLoaded = false;
  bool producersDataLoaded = false;
  bool writersDataLoaded = false;
  bool studiosDataLoaded = false;
  List<Map<String, dynamic>> charactersData = [];
  List<Map<String, dynamic>> producersData = [];
  List<Map<String, dynamic>> studiosData = [];
  List<Map<String, dynamic>> writersData = [];
  List<Map<String, dynamic>> creatorsData = [];
  List<Map<String, dynamic>> publishersData = [];

  String MoneyString(String array) {
    int arrayL = array.length;
    String? str = "";

    if (arrayL / 12 > 1) {
      str = money[12];
    }

    if (arrayL / 9 > 1 && arrayL / 9 < 2) {
      str = money[9];
    }
    if (arrayL / 6 > 1 && arrayL / 6 < 2) {
      str = money[6];
    }
    if (arrayL / 3 > 1 && arrayL / 3 < 2) {
      str = money[3];
    }
    if (str != "") {
      return array[0] + array[1] + array[2] + ' ' + str! + ' \$';
    } else {
      return array[0] + array[1] + array[2] + ' \$';
    }
  }

  Map<int, String> money = {
    3: "mille",
    6: "millions",
    9: "milliards",
    12: "billions",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getCharactersData();
    fetchInfos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getCharactersData() async {
    final response = await http.get(Uri.parse(
        widget.url + "?api_key=${DetailsMoviesPage.apiKey}&format=json"));

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
            '$characterDetailUrl?api_key=${DetailsMoviesPage.apiKey}&format=json'));

        if (characterDetailResponse.statusCode == 200) {
          Map<String, dynamic> characterData =
          json.decode(characterDetailResponse.body);
          String imageUrl = characterData['results']['image']['original_url'];
          String Histoire =
              characterData['results']['description'] ?? 'Unknown';

          String realName = characterData['results']['real_name'] ?? 'Unknown';
          String alias = characterData['results']['aliases'] ?? 'Unknown';
          int genre = characterData['results']['gender'];
          String birth = characterData['results']['birth'] ?? 'Incconue';
          String death = characterData['results']['death'] ?? 'N/A';

          Map<String, dynamic> publisherMap =
              characterData['results']['publisher'] ?? {'name': 'Unknown'};
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
            'description': Histoire,
            'realName': realName,
            'alias': alias,
            'genre': genre,
            'birth': birth,
            'death': death,
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

  void fetchInfos() async {
    try {
      final response = await http.get(Uri.parse(
          widget.url + "?api_key=${DetailsMoviesPage.apiKey}&format=json"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        String bud = jsonData['results']['budget'] ?? 'Unknown';
        String box = jsonData['results']['box_office_revenue'] ?? 'Unknown';

        String rate = jsonData['results']['rating'].runtimeType == String
            ? jsonData['results']['rating']
            : 'Unknown';
        String tot = jsonData['results']['total_revenue'].runtimeType == String
            ? jsonData['results']['total_revenue']
            : 'Unknown';

        budget = MoneyString(bud);
        box_revenue = MoneyString(box);
        tot_revenue = MoneyString(tot);

        setState(() {
          budget;
          box_revenue;
          rating = rate;
          tot_revenue;
        });

        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> producers = data['results']['producers'];
        for (var producer in producers) {
          producersData.add({
            'name': producer['name'],
          });
          producersDataLoaded = true;
        }
        List<dynamic> studios = data['results']['studios'];
        for (var studio in studios) {
          studiosData.add({
            'name': studio['name'],
          });
          studiosDataLoaded = true;
        }
        List<dynamic> writers = data['results']['writers'];
        for (var writer in writers) {
          writersData.add({
            'name': writer['name'],
          });
          writersDataLoaded = true;
        }
      } else {
        print('Erreur de requête: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la description: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.moviesName,
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
                                  'res/svg/navbar_movies.svg',
                                  width: 16,
                                  height: 15,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                  height: 15,
                                ),
                                Text(
                                  '${widget.runtimeMovies} minutes',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
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
                                '${widget.addedData}',
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
                    Tab(text: 'Synopsis'),
                    Tab(text: 'Personnages'),
                    Tab(text: 'Infos'),
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
                        SynopsisTab(synopsis: widget.synopsis),
                        charactersDataLoaded
                            ? CharactersMoviesTab(
                            charactersData: charactersData,
                            creatorsData: creatorsData,
                            publishersData: publishersData)
                            : Center(child: CircularProgressIndicator()),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              // Espacement entre les deux textes

                              InfosTab(
                                writersData: writersData,
                                producersData: producersData,
                                studiosData: studiosData,
                                budget: budget,
                                boxRevenue: box_revenue,
                                rating: rating,
                                totRevenue: tot_revenue,
                              )
                            ],
                          ),
                        ),
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

class SynopsisTab extends StatelessWidget {
  final String synopsis;

  SynopsisTab({required this.synopsis});

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
              '${extractDescription(synopsis)}',
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

class CharactersMoviesTab extends StatelessWidget {
  final List<Map<String, dynamic>> charactersData;
  final List<Map<String, dynamic>> creatorsData;
  final List<Map<String, dynamic>> publishersData;

  CharactersMoviesTab(
      {required this.charactersData,
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
                      publishersData: publishersData,
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
                          fontWeight: FontWeight.w600),
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

class InfosTab extends StatelessWidget {
  final List<Map<String, dynamic>> writersData;
  final List<Map<String, dynamic>> producersData;
  final List<Map<String, dynamic>> studiosData;
  final String? budget;
  final String? boxRevenue;
  final String? rating;
  final String? totRevenue;

  InfosTab({
    required this.writersData,
    required this.producersData,
    required this.studiosData,
    required this.budget,
    required this.boxRevenue,
    required this.rating,
    required this.totRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (budget != null && budget != 'Unknown')
            _buildInfoItem('Budget', budget!),
          if (boxRevenue != null && boxRevenue != 'Unknown')
            _buildInfoItem('Box Revenue', boxRevenue!),
          if (rating != null && rating != 'Unknown')
            _buildInfoItem('Rating', rating!),
          if (totRevenue != null && totRevenue != 'Unknown')
            _buildInfoItem('Total Revenue', totRevenue!),
          SizedBox(height: 20),
          if (writersData.isNotEmpty)
            _buildListInfoItem('Writers', writersData),
          SizedBox(height: 20),
          if (producersData.isNotEmpty)
            _buildListInfoItem('Producers', producersData),
          SizedBox(height: 20),
          if (studiosData.isNotEmpty)
            _buildListInfoItem('Studios', studiosData),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _buildListInfoItem(String title, List<Map<String, dynamic>> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var item in data)
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 8),
                  child: Text(
                    item['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
