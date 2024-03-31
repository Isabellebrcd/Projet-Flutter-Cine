import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:test_api2/series_details.dart';
import 'main.dart';
import 'comics.dart';
import 'films.dart';
import 'search.dart';


class SeriesPage extends StatelessWidget {

  static const String apiKey = '1159b9ddc377bf342b90fe1100fd57522cde7a5f';
  static const String seriesEndpoint =
      'series_list'; // Endpoint pour les series

  // Fonction pour récupérer les données de toutes les séries depuis l'API
  Future<List<Map<String, dynamic>>> fetchAllSeries() async {
    final response = await http.get(Uri.parse(
        'https://comicvine.gamespot.com/api/$seriesEndpoint?api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des séries
      List<dynamic> series = data['results'] as List<dynamic>;
      List<Map<String, dynamic>> seriesData = [];

      for (int i = 0; i < 50; i++) {
        String publisherName = series[i]['publisher'] != null
            ? series[i]['publisher']['name']
            : 'Unknown';

        String histoire = series[i]['description'].runtimeType == String
            ? series[i]['description']
            : "Unknown";

        seriesData.add({
          'name': series[i]['name'],
          'image': series[i]['image']['original_url'],
          'start_year': series[i]['start_year'],
          'count_of_episodes': series[i]['count_of_episodes'],
          'publisher': publisherName,
          'api_url' : series[i]['api_detail_url'],
          'histoire' : histoire,
        });
      }

      return seriesData;
    } else {
      // Si la requête a échoué, lancer une exception
      throw Exception('Failed to load episodes');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      body: FutureBuilder(
        future: fetchAllSeries(),
        builder: (context, seriesSnapshot) {
          if (seriesSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularPercentIndicator(
                backgroundColor: AppColors.backgroundScreen,
                radius: 100.0,
                lineWidth: 10.0,
                percent: 90 / 100,
                animation: true,
                animationDuration: 4000,
                center: Text(
                  "90%",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                footer: Text(
                  "Chargement en cours",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                progressColor: AppColors.orange,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            );
          } else if (seriesSnapshot.hasError) {
            return Center(child: Text('Error: ${seriesSnapshot.error}'));
          } else {
            List<Map<String, dynamic>> series =
            seriesSnapshot.data as List<Map<String, dynamic>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 290,
                  padding: EdgeInsets.only(top : 32, left: 32),
                  child: Text(
                    'Séries les plus populaires',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    softWrap: true,
                  ),
                ),
                Expanded(
                    child: ListView.separated(
                      itemCount: series.length >= 50 ? 50 : series.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        // Récupérer les données de la série à cet index
                        Map<String, dynamic> seriesData = series[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                      seriesName: seriesData['name'],
                                      imageUrl: seriesData['image'],
                                      publisher: seriesData['publisher'],
                                      episodeCount: seriesData['count_of_episodes'].toString(), // Convert to string
                                      startYear: seriesData['start_year'].toString(),
                                      url: seriesData['api_url'],
                                      histoire : seriesData['histoire']
                                  ),
                                ),
                              );
                            },
                            child : Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              // Ajouter des marges horizontales
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundCards,
                                  // Changer la couleur de fond du conteneur
                                  borderRadius: BorderRadius.circular(
                                      10),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        // Stack pour l'image
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              // Donner des bords arrondis à l'image
                                              child: Image.network(
                                                seriesData['image'],
                                                width: 128,
                                                height: 132,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Stack pour le rectangle orange
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          // Décalez le conteneur orange vers le haut
                                          child: Container(
                                            width: 59, // Largeur fixe pour le cercle orange
                                            height: 40, // Hauteur du conteneur orange
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              // Couleur de fond orange
                                              shape: BoxShape.rectangle,
                                              // Forme de cercle
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '#${index + 1}',
                                                // Index commence à 0, donc on ajoute 1 pour afficher le numéro du conteneur
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 230,
                                          child: Text(
                                            seriesData['name'],
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'res/svg/ic_publisher_bicolor.svg',
                                              width: 15,
                                              height: 12,
                                              color: AppColors.textBottomBar,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              seriesData['publisher'],
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.start,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'res/svg/ic_tv_bicolor.svg',
                                              width: 14,
                                              height: 14,
                                              color: AppColors.textBottomBar,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              '${seriesData['count_of_episodes'].toString()} épisodes',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.start,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'res/svg/ic_calendar_bicolor.svg',
                                              width: 16,
                                              height: 15,
                                              color: AppColors.textBottomBar,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              '${seriesData['start_year'].toString()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.start,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                        );

                      },
                    )

                ),
              ],
            );
          }
        },
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
                          'res/svg/navbar_series.svg',
                          width: 24.01,
                          height: 24.01,
                          color: AppColors.textBottomBarSelected,
                        ),
                        Text(
                          'Series',
                          style:
                          TextStyle(color: AppColors.textBottomBarSelected),
                        ),
                      ],
                    ),
                  ),
                ],
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
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