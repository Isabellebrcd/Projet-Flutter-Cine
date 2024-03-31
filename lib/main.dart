import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'series.dart';
import 'comics.dart';
import 'films.dart';
import 'search.dart';
import 'series_details.dart';
import 'films_details.dart';
import 'comics_details.dart';
import 'package:url_launcher/url_launcher.dart';

class AppColors {
  static const Color backgroundScreen = Color.fromRGBO(21, 35, 46, 1.0);
  static const Color orange = Color.fromRGBO(255, 129, 0, 1.0);
  static const Color backgroundCards = Color.fromRGBO(30, 50, 67, 1.0);
  static const Color backgroundElementCard = Color.fromRGBO(40, 76, 106, 1.0);
  static const Color backgroundSeeMore = Color.fromRGBO(15, 25, 33, 1.0);
  static const Color backgroundBottomBar = Color.fromRGBO(21, 35, 46, 1.0);
  static const Color backgroundBottomBarSelected =
      Color.fromRGBO(18, 39, 60, 1.0);
  static const Color textBottomBarSelected = Color.fromRGBO(55, 146, 255, 1.0);
  static const Color textBottomBar = Color.fromRGBO(119, 139, 168, 1.0);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comics App',
      theme: ThemeData(fontFamily: 'Nunito'),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // URL de l'API et votre clé API
  static const String apiKey = '1159b9ddc377bf342b90fe1100fd57522cde7a5f';
  static const String apiKey2 = 'a475892242077f46a2a9f59f148f03332f742e08';
  static const String articlesEndpoint = 'articles';
  static const String movieEndpoint = 'movies'; // Endpoint pour les films
  static const String seriesEndpoint =
      'series_list'; // Endpoint pour les series
  static const String comicsEndpoint = 'issues'; // Endpoint pour les comics
  static const String charactersEndpoint =
      'characters'; // Endpoint pour les perso

  Future<List<Map<String, dynamic>>> fetchPopularArticles() async {
    final response = await http.get(Uri.parse(
        'http://www.gamespot.com/api/$articlesEndpoint?api_key=$apiKey2&format=json&sort=publish_date:desc'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des films
      List<dynamic> articles = data['results'] as List;
      List<Map<String, dynamic>> articleData = [];
      for (int i = 0; i < articles.length && i < 2; i++) {
        articleData.add({
          'title': articles[i]['title'],
          'image': articles[i]['image']['original'],
        });
      }
      return articleData;
    } else {
      // Si la requête a échoué, lancer une exception
      throw Exception('Failed to load popular movies');
    }
  }

  // Fonction pour récupérer les données des films depuis l'API
  Future<List<Map<String, dynamic>>> fetchPopularMovies() async {
    final response = await http.get(Uri.parse(
        'https://comicvine.gamespot.com/api/$movieEndpoint?api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des films
      List<dynamic> movies = data['results'] as List;
      List<Map<String, dynamic>> movieData = [];
      for (int i = 0; i < movies.length && i < 5; i++) {
        movieData.add({
          'name': movies[i]['name'],
          'image': movies[i]['image']['original_url'],
        });
      }
      return movieData;
    } else {
      // Si la requête a échoué, lancer une exception
      throw Exception('Failed to load popular movies');
    }
  }

  // Fonction pour récupérer les données de toutes les séries depuis l'API
  Future<List<Map<String, dynamic>>> fetchAllSeries() async {
    final response = await http.get(Uri.parse(
        'https://comicvine.gamespot.com/api/$seriesEndpoint?api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des séries
      List<dynamic> series = data['results'] as List;
      List<Map<String, dynamic>> seriesData = [];
      for (int i = 0; i < series.length && i < 5; i++) {
        seriesData.add({
          'name': series[i]['name'],
          'image': series[i]['image']['original_url'],
        });
      }
      return seriesData;
    } else {
      // Si la requête a échoué, lancer une exception
      throw Exception('Failed to load episodes');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllComics() async {
    final response = await http.get(Uri.parse(
        'https://comicvine.gamespot.com/api/$comicsEndpoint?api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des séries
      List<dynamic> comics = data['results'] as List;
      List<Map<String, dynamic>> comicsData = [];
      for (int i = 0; i < comics.length && i < 5; i++) {
        comicsData.add({
          'name': comics[i]['volume']['name'],
          'image': comics[i]['image']['original_url'],
        });
      }
      return comicsData;
    } else {
      // Si la requête a échoué, lancer une exception
      throw Exception('Failed to load episodes');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllCharacters() async {
    final response = await http.get(Uri.parse(
        'https://comicvine.gamespot.com/api/$charactersEndpoint?api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des séries
      List<dynamic> characters = data['results'] as List;
      List<Map<String, dynamic>> charactersData = [];
      for (int i = 0; i < characters.length && i < 5; i++) {
        charactersData.add({
          'name': characters[i]['name'],
          'image': characters[i]['image']['original_url'],
        });
      }
      return charactersData;
    } else {
      // Si la requête a échoué, lancer une exception
      throw Exception('Failed to load episodes');
    }
  }

  _launchURL() async {
    const url = 'https://www.gamespot.com/news/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible de lancer $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      body: FutureBuilder(
        future: fetchPopularMovies(),
        builder: (context, movieSnapshot) {
          if (movieSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularPercentIndicator(
              backgroundColor: AppColors.backgroundScreen,
              radius: 100.0,
              lineWidth: 10.0,
              percent: 60 / 100,
              animation: true,
              animationDuration: 2000,
              center: Text(
                "60%",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              footer: Text(
                "Chargement en cours",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              progressColor: AppColors.orange,
              circularStrokeCap: CircularStrokeCap.round,
            ));
          } else if (movieSnapshot.hasError) {
            return Center(child: Text('Error: ${movieSnapshot.error}'));
          } else {
            List<Map<String, dynamic>> movies =
                movieSnapshot.data as List<Map<String, dynamic>>;

            return FutureBuilder(
              future: fetchAllSeries(),
              // Utilisation de fetchAllSeries() pour récupérer toutes les séries
              builder: (context, seriesSnapshot) {
                if (seriesSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularPercentIndicator(
                    backgroundColor: AppColors.backgroundScreen,
                    radius: 100.0,
                    lineWidth: 10.0,
                    percent: 70 / 100,
                    //animation: true,
                    //animationDuration: 1800,
                    center: Text(
                      "70%",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    footer: Text(
                      "Chargement toujours en cours",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    progressColor: AppColors.orange,
                    circularStrokeCap: CircularStrokeCap.round,
                  ));
                } else if (seriesSnapshot.hasError) {
                  return Center(child: Text('Error: ${seriesSnapshot.error}'));
                } else {
                  List<Map<String, dynamic>> series =
                      seriesSnapshot.data as List<Map<String, dynamic>>;

                  return FutureBuilder(
                      future: fetchPopularArticles(),
                      builder: (context, articlesSnapshot) {
                        if (articlesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularPercentIndicator(
                            backgroundColor: AppColors.backgroundScreen,
                            radius: 100.0,
                            lineWidth: 10.0,
                            percent: 80 / 100,
                            //animation: true,
                            //animationDuration: 1800,
                            center: Text(
                              "80%",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            footer: Text(
                              "Patiente encore un peu",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            progressColor: AppColors.orange,
                            circularStrokeCap: CircularStrokeCap.round,
                          ));
                        } else if (articlesSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${articlesSnapshot.error}'));
                        } else {
                          List<Map<String, dynamic>> articles =
                              articlesSnapshot.data as List<Map<String, dynamic>>;

                          return FutureBuilder(
                              future: fetchAllComics(),
                              builder: (context, comicsSnapchot) {
                                if (comicsSnapchot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularPercentIndicator(
                                    backgroundColor: AppColors.backgroundScreen,
                                    radius: 100.0,
                                    lineWidth: 10.0,
                                    percent: 90 / 100,
                                    //animation: true,
                                    //animationDuration: 1800,
                                    center: Text(
                                      "90%",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    footer: Text(
                                      "On y est presque",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    progressColor: AppColors.orange,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ));
                                } else if (comicsSnapchot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${comicsSnapchot.error}'));
                                } else {
                                  List<Map<String, dynamic>> comics =
                                      comicsSnapchot.data
                                          as List<Map<String, dynamic>>;

                                  return FutureBuilder(
                                      future: fetchAllCharacters(),
                                      builder: (context, charactersSnapchot) {
                                        if (charactersSnapchot
                                                .connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularPercentIndicator(
                                            backgroundColor:
                                                AppColors.backgroundScreen,
                                            radius: 100.0,
                                            lineWidth: 10.0,
                                            percent: 100 / 100,
                                            //animation: true,
                                            //animationDuration: 1800,
                                            center: Text(
                                              "100%",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                            footer: Text(
                                              "Chargement terminé",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                            progressColor: AppColors.orange,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                          ));
                                        } else if (charactersSnapchot
                                            .hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${charactersSnapchot.error}'));
                                        } else {
                                          List<Map<String, dynamic>>
                                              characters =
                                              charactersSnapchot.data
                                                  as List<Map<String, dynamic>>;

                                          return SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(0, 0, 0, 0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        //flex: 2,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0.0,
                                                                  1.0,
                                                                  0.0,
                                                                  2.0),
                                                          height: 110,
                                                          //color: AppColors.orange,
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'Bienvenue !',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  25.0,
                                                                  16.0,
                                                                  0.0,
                                                                  2.0),
                                                          height: 170,
                                                          //color: AppColors.orange,
                                                          child:
                                                              SvgPicture.asset(
                                                            'res/svg/astronaut.svg',
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      12.0, 12.0, 12.0, 4.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 349,
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topStart,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 20.0,
                                                    ),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors
                                                          .backgroundCards,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                20.0),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 10,
                                                                  height: 10,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColors
                                                                        .orange,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 9),
                                                                Text(
                                                                  'Films populaires',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 25),
                                                            Positioned(
                                                              top: -9,
                                                              right: 0,
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                      pageBuilder: (context,
                                                                              animation1,
                                                                              animation2) =>
                                                                          FilmsPage(),
                                                                      transitionsBuilder: (context,
                                                                          animation1,
                                                                          animation2,
                                                                          child) {
                                                                        return child;
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .backgroundSeeMore,
                                                                ),
                                                                child: Text(
                                                                  'Voir plus',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                        Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              children: movies
                                                                      .isNotEmpty
                                                                  ? movies.map(
                                                                      (movie) {
                                                                      return Container(
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                10.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              width: 180,
                                                                              height: 240,
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.backgroundElementCard,
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 180,
                                                                                    height: 177,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(10.0),
                                                                                        topRight: Radius.circular(10.0),
                                                                                      ),
                                                                                      image: movie['image'] != null
                                                                                          ? DecorationImage(
                                                                                              image: NetworkImage(movie['image']),
                                                                                              fit: BoxFit.cover,
                                                                                            )
                                                                                          : null,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(left: 11.0),
                                                                                    child: Text(
                                                                                      movie['name'] ?? "",
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
                                                                      );
                                                                    }).toList()
                                                                  : [
                                                                      Container(
                                                                          child:
                                                                              Text("No movies found"))
                                                                    ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      12.0, 12.0, 12.0, 4.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 349,
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topStart,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 20.0,
                                                    ),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors
                                                          .backgroundCards,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                20.0),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 10,
                                                                  height: 10,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColors
                                                                        .orange,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 9),
                                                                Text(
                                                                  'Séries populaires',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 25),
                                                            Positioned(
                                                              top: -9,
                                                              right: 0,
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                      pageBuilder: (context,
                                                                              animation1,
                                                                              animation2) =>
                                                                          SeriesPage(),
                                                                      transitionsBuilder: (context,
                                                                          animation1,
                                                                          animation2,
                                                                          child) {
                                                                        return child;
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .backgroundSeeMore,
                                                                ),
                                                                child: Text(
                                                                  'Voir plus',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                        Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              children: series
                                                                      .isNotEmpty
                                                                  ? series.map(
                                                                      (series) {
                                                                      return Container(
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                10.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              width: 180,
                                                                              height: 240,
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.backgroundElementCard,
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 180,
                                                                                    height: 177,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(10.0),
                                                                                        topRight: Radius.circular(10.0),
                                                                                      ),
                                                                                      image: series['image'] != null
                                                                                          ? DecorationImage(
                                                                                              image: NetworkImage(series['image']),
                                                                                              fit: BoxFit.cover,
                                                                                            )
                                                                                          : null,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(left: 11.0),
                                                                                    child: Text(
                                                                                      series['name'] ?? "",
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
                                                                      );
                                                                    }).toList()
                                                                  : [
                                                                      Container(
                                                                          child:
                                                                              Text("No movies found"))
                                                                    ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      12.0, 12.0, 12.0, 4.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 349,
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topStart,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 20.0,
                                                    ),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors
                                                          .backgroundCards,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                20.0),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 10,
                                                                  height: 10,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColors
                                                                        .orange,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 9),
                                                                Text(
                                                                  'Comics populaires',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 25),
                                                            Positioned(
                                                              top: -9,
                                                              right: 0,
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                      pageBuilder: (context,
                                                                              animation1,
                                                                              animation2) =>
                                                                          ComicsPage(),
                                                                      transitionsBuilder: (context,
                                                                          animation1,
                                                                          animation2,
                                                                          child) {
                                                                        return child;
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .backgroundSeeMore,
                                                                ),
                                                                child: Text(
                                                                  'Voir plus',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                        Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              children: comics
                                                                      .isNotEmpty
                                                                  ? comics.map(
                                                                      (comics) {
                                                                      return Container(
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                10.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              width: 180,
                                                                              height: 240,
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.backgroundElementCard,
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 180,
                                                                                    height: 177,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(10.0),
                                                                                        topRight: Radius.circular(10.0),
                                                                                      ),
                                                                                      image: comics['image'] != null
                                                                                          ? DecorationImage(
                                                                                              image: NetworkImage(comics['image']),
                                                                                              fit: BoxFit.cover,
                                                                                            )
                                                                                          : null,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(left: 11.0),
                                                                                    child: Text(
                                                                                      comics['name'] ?? "",
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
                                                                      );
                                                                    }).toList()
                                                                  : [
                                                                      Container(
                                                                          child:
                                                                              Text("No Comics found"))
                                                                    ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      12.0, 12.0, 12.0, 4.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 349,
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topStart,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 20.0,
                                                    ),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors
                                                          .backgroundCards,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                20.0),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 10,
                                                                  height: 10,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColors
                                                                        .orange,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 9),
                                                                Text(
                                                                  'Personnages populaires',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 25),

                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                        Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              children: characters
                                                                      .isNotEmpty
                                                                  ? characters.map(
                                                                      (characters) {
                                                                      return Container(
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                10.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              width: 180,
                                                                              height: 240,
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.backgroundElementCard,
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 180,
                                                                                    height: 177,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(10.0),
                                                                                        topRight: Radius.circular(10.0),
                                                                                      ),
                                                                                      image: characters['image'] != null
                                                                                          ? DecorationImage(
                                                                                              image: NetworkImage(characters['image']),
                                                                                              fit: BoxFit.cover,
                                                                                            )
                                                                                          : null,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(left: 11.0),
                                                                                    child: Text(
                                                                                      characters['name'] ?? "",
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
                                                                      );
                                                                    }).toList()
                                                                  : [
                                                                      Container(
                                                                          child:
                                                                              Text("No Characters found"))
                                                                    ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      12.0, 12.0, 12.0, 4.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 370,
                                                    alignment:
                                                    AlignmentDirectional
                                                        .topStart,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 20.0,
                                                    ),
                                                    decoration:
                                                    const BoxDecoration(
                                                      color: AppColors
                                                          .backgroundCards,
                                                      borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                        Radius.circular(
                                                            20.0),
                                                        bottomLeft:
                                                        Radius.circular(
                                                            20.0),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: [
                                                                Container(
                                                                  width: 10,
                                                                  height: 10,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    color: AppColors
                                                                        .orange,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 9),
                                                                Text(
                                                                  'Actualités',
                                                                  style:
                                                                  TextStyle(
                                                                    fontSize:
                                                                    20,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 25),
                                                            Positioned(
                                                              top: -9,
                                                              right: 0,
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  _launchURL();
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                      8),
                                                                  backgroundColor:
                                                                  AppColors
                                                                      .backgroundSeeMore,
                                                                ),
                                                                child: Text(
                                                                  'Voir plus',
                                                                  style:
                                                                  TextStyle(
                                                                    fontSize:
                                                                    14,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                        Expanded(
                                                          child:
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                            Axis.horizontal,
                                                            child: Row(
                                                              children: articles
                                                                  .isNotEmpty
                                                                  ? articles.map(
                                                                      (articles) {
                                                                    return Container(
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                          10.0),
                                                                      child:
                                                                      Column(
                                                                        children: [
                                                                          Container(
                                                                            width: 210,
                                                                            height: 260,
                                                                            decoration: BoxDecoration(
                                                                              color: AppColors.backgroundElementCard,
                                                                              borderRadius: BorderRadius.circular(10.0),
                                                                            ),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                              children: [
                                                                                Container(
                                                                                  width: 180,
                                                                                  height: 177,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.only(
                                                                                      topLeft: Radius.circular(10.0),
                                                                                      topRight: Radius.circular(10.0),
                                                                                    ),
                                                                                    image: articles['image'] != null
                                                                                        ? DecorationImage(
                                                                                      image: NetworkImage(articles['image']),
                                                                                      fit: BoxFit.cover,
                                                                                    )
                                                                                        : null,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 10),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: 11.0),
                                                                                  child: Text(
                                                                                    articles['title'] ?? "",
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
                                                                    );
                                                                  }).toList()
                                                                  : [
                                                                Container(
                                                                    child:
                                                                    Text("No articles found"))
                                                              ],
                                                            ),
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
                                      });
                                }
                              });
                        }
                      });
                }
              },
            );
          }
        },
      ),
      /////////////////////////////////////BOTTOM BAR///////////////////////////////
      /*bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: SvgPicture.asset('res/svg/navbar_home.svg'), label: 'Accueil'),
          BottomNavigationBarItem(icon: SvgPicture.asset('res/svg/navbar_comics.svg'), label: 'Comics'),
          BottomNavigationBarItem(icon: SvgPicture.asset('res/svg/navbar_series.svg'), label: 'Series'),
          BottomNavigationBarItem(icon: SvgPicture.asset('res/svg/navbar_movies.svg'), label: 'Movies'),
          BottomNavigationBarItem(icon: SvgPicture.asset('res/svg/navbar_search.svg'), label: 'Search'),

        ],
      ),*/
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
                          'res/svg/navbar_home.svg',
                          width: 24.01,
                          height: 24.01,
                          color: AppColors.textBottomBarSelected,
                        ),
                        Text(
                          'Accueil',
                          style:
                              TextStyle(color: AppColors.textBottomBarSelected),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Icon 2
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
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
                  Navigator.push(
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
                      'Séries',
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
                  Navigator.push(
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SearchPage(),
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
                      'res/svg/navbar_search.svg',
                      width: 24.01,
                      height: 24.01,
                      color: AppColors.textBottomBar,
                    ),
                    Text(
                      'Recherche',
                      style: TextStyle(color: AppColors.textBottomBar),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
