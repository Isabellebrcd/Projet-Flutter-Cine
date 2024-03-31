import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'main.dart';
import 'series.dart';
import 'comics.dart';
import 'films.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<dynamic>> results = {};
  bool isSearching = false;

  void _search() async {
    setState(() {
      isSearching = true;
    });

    final apiKey = '9f0bb9bce7f9154f43645e7d6cb131a10fe20346';
    final query = _searchController.text;
    final url = Uri.parse(
        'https://comicvine.gamespot.com/api/search/?api_key=$apiKey&format=json&query=$query&resources=issue,movie,series,character, episodes');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        results = {
          'Comics': jsonData['results']
              .where((result) => result['resource_type'] == 'issue')
              .toList(),
          'Movies': jsonData['results']
              .where((result) => result['resource_type'] == 'movie')
              .toList(),
          'Series': jsonData['results']
              .where((result) => result['resource_type'] == 'series')
              .toList(),
          'Characters': jsonData['results']
              .where((result) => result['resource_type'] == 'character')
              .toList(),
          'Episodes': jsonData['results']
              .where((result) => result['resource_type'] == 'episodes')
              .toList(),
        };
        isSearching = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(163.0),
        child: AppBar(
          leading: SizedBox.shrink(),
          backgroundColor: AppColors.backgroundCards,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35.0),
              bottomRight: Radius.circular(35.0),
            ),
          ),
          flexibleSpace: Stack(
            children: [
              Positioned(
                left: 30.0,
                bottom: 21.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundScreen,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: 350,
                  height: 50.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Comic, film, série...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: AppColors.textBottomBar, fontSize: 17),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.search, color: AppColors.textBottomBar),
                        onPressed: _search,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 30.0,
                bottom: 88.0,
                child: Text(
                  'Recherche',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          isSearching
              ? Center(
                  child: Container(
                    width: 348,
                    height: 131,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -170,
                          child: SvgPicture.asset(
                            'res/svg/astronaut.svg',
                            height: 207,
                            width: 158,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Recherche en cours.", // Texte à afficher
                              style: TextStyle(
                                color:
                                AppColors.textBottomBarSelected, // Couleur du texte en blanc
                                fontSize: 15.0, // Taille de la police
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "Merci de patienter...", // Texte à afficher
                              style: TextStyle(
                                color:
                                    AppColors.textBottomBarSelected, // Couleur du texte en blanc
                                fontSize: 15.0, // Taille de la police
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCards,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )
              : results.isNotEmpty
                  ? SearchTab(results: results)
                  : Center(
                      child: Column(
                        children: [
                          const Spacer(),
                          Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: 348,
                                  height: 131,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCards,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                        width: 199,
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: AppColors
                                                  .textBottomBarSelected,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: _searchController
                                                        .text.isEmpty
                                                    ? 'Saisissez une recherche pour trouver un '
                                                    : 'Aucun résultat trouvé',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textBottomBarSelected,
                                                ),
                                              ),
                                              if (_searchController
                                                  .text.isEmpty)
                                                TextSpan(
                                                  text: 'comics',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .textBottomBarSelected,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              TextSpan(
                                                text: _searchController
                                                        .text.isEmpty
                                                    ? ', '
                                                    : '',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textBottomBarSelected,
                                                ),
                                              ),
                                              if (_searchController
                                                  .text.isEmpty)
                                                TextSpan(
                                                  text: 'film',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .textBottomBarSelected,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              TextSpan(
                                                text: _searchController
                                                        .text.isEmpty
                                                    ? ', '
                                                    : '',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textBottomBarSelected,
                                                ),
                                              ),
                                              if (_searchController
                                                  .text.isEmpty)
                                                TextSpan(
                                                  text: 'série',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .textBottomBarSelected,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              TextSpan(
                                                text: _searchController
                                                        .text.isEmpty
                                                    ? ', ou '
                                                    : '',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textBottomBarSelected,
                                                ),
                                              ),
                                              if (_searchController
                                                  .text.isEmpty)
                                                TextSpan(
                                                  text: 'personnage.',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .textBottomBarSelected,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                                Positioned(
                                  right: 25,
                                  top: -25,
                                  child: SvgPicture.asset(
                                      "res/svg/astronaut.svg",
                                      width: 100,
                                      height: 100),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
        ],
      ),
      bottomNavigationBar: Container(
        width: 375,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.backgroundBottomBar,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF15232E),
              offset: Offset(2, 6),
              blurRadius: 20,
            ),
            BoxShadow(
              color: Color(0xFF6F8FEA),
              offset: Offset(4, 16),
              blurRadius: 52,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon 1
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          HomePage(),
                      transitionsBuilder:
                          (context, animation1, animation2, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'res/svg/navbar_home.svg',
                      width: 24.01,
                      height: 24.01,
                      color: AppColors.textBottomBar,
                    ),
                    Text(
                      'Accueil',
                      style: TextStyle(color: AppColors.textBottomBar),
                    ),
                  ],
                ),
              ),
            ),
            // Icon 2
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          ComicsPage(),
                      transitionsBuilder:
                          (context, animation1, animation2, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'res/svg/navbar_comics.svg',
                      width: 24.01,
                      height: 24.01,
                      color: AppColors.textBottomBar,
                    ),
                    Text(
                      'Comics',
                      style: TextStyle(color: AppColors.textBottomBar),
                    ),
                  ],
                ),
              ),
            ),
            // Icon 3
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SeriesPage(),
                      transitionsBuilder:
                          (context, animation1, animation2, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'res/svg/navbar_series.svg',
                      width: 24.01,
                      height: 24.01,
                      color: AppColors.textBottomBar,
                    ),
                    Text(
                      'Series',
                      style: TextStyle(color: AppColors.textBottomBar),
                    ),
                  ],
                ),
              ),
            ),
            // Icon 4
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          FilmsPage(),
                      transitionsBuilder:
                          (context, animation1, animation2, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'res/svg/navbar_movies.svg',
                      width: 24.01,
                      height: 24.01,
                      color: AppColors.textBottomBar,
                    ),
                    Text(
                      'Films',
                      style: TextStyle(color: AppColors.textBottomBar),
                    ),
                  ],
                ),
              ),
            ),
            // Icon 5
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBottomBarSelected,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'res/svg/navbar_search.svg',
                          width: 24.01,
                          height: 24.01,
                          color: AppColors.textBottomBarSelected,
                        ),
                        Text(
                          'Recherche',
                          style:
                              TextStyle(color: AppColors.textBottomBarSelected),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTab extends StatelessWidget {
  final Map<String, List<dynamic>> results;

  SearchTab({required this.results});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Catégorie Comics
          SizedBox(height: 20),
          if (results['Comics'] != null && results['Comics']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: double.infinity,
                height: 349,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCards,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Comics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final result in results['Comics']!)
                            Container(
                              margin: EdgeInsets.only(left: 15, top: 15),
                              // Ajout de la marge à droite du conteneur rouge
                              width: 180,
                              height: 242,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElementCard,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      result['image']['original_url'],
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: EdgeInsets.only(left: 11.0),
                                    child: Text(
                                      '${result['volume']['name']}' ?? "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.start,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20),
          // Catégorie Films
          if (results['Movies'] != null && results['Movies']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: double.infinity,
                height: 349,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCards,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17),
                              // Ajout de la marge à droite du cercle orange
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Movies',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final result in results['Movies']!)
                            Container(
                              margin: EdgeInsets.only(left: 15, top: 15),
                              // Ajout de la marge à droite du conteneur rouge
                              width: 180,
                              height: 242,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElementCard,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      result['image']['original_url'],
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: EdgeInsets.only(left: 11.0),
                                    child: Text(
                                      '${result['name']}' ?? "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.start,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          //SizedBox(height: 20),
          // Catégorie Séries
          if (results['Series'] != null && results['Series']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: double.infinity,
                height: 349,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCards,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Séries',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final result in results['Series']!)
                            Container(
                              margin: EdgeInsets.only(left: 15, top: 15),
                              width: 180,
                              height: 242,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElementCard,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      result['image']['original_url'],
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: EdgeInsets.only(left: 11.0),
                                    child: Text(
                                      '${result['name']}' ?? "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.start,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20),
          // Catégorie Personnages
          if (results['Characters'] != null &&
              results['Characters']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: double.infinity,
                height: 349,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCards,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Personnages',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final result in results['Characters']!)
                            Container(
                              margin: EdgeInsets.only(left: 15, top: 15),
                              width: 180,
                              height: 242,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElementCard,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      result['image']['original_url'],
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: EdgeInsets.only(left: 11.0),
                                    child: Text(
                                      '${result['name']}' ?? "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.start,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
