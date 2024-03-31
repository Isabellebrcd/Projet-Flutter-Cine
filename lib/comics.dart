import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'comics_details.dart';
import 'main.dart';
import 'series.dart';
import 'films.dart';
import 'search.dart';
import 'series_details.dart';

class ComicsPage extends StatelessWidget {
  static const String apiKey = '1159b9ddc377bf342b90fe1100fd57522cde7a5f';
  static const String comicsEndpoint =
      'issues'; // Endpoint pour les series

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


  // Fonction pour récupérer les données de toutes les séries depuis l'API
  Future<List<Map<String, dynamic>>> fetchAllComics() async {
    final response = await http.get(Uri.parse(
        'https://comicvine.gamespot.com/api/$comicsEndpoint?api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      // Si la requête est réussie, décoder les données JSON
      Map<String, dynamic> data = json.decode(response.body);
      // Récupérer les noms et les URL des images des comics
      List<dynamic> comics = data['results'] as List<dynamic>;
      List<Map<String, dynamic>> comicsData = [];


      for (int i = 0; i < 50; i++) {


        String name = comics[i]['name'].runtimeType == String
            ? comics[i]['name']
            : "Unknown";



        String coverDate = comics[i]['cover_date'];
        DateTime parsedDate = DateTime.parse(coverDate);
        String formattedYear = DateFormat(' yyyy').format(parsedDate);
        String formattedMonth = DateFormat('MM').format(parsedDate);


        comicsData.add({
          'name': name,
          'image': comics[i]['image']['original_url'],
          'name_volume' : comics[i]['volume']['name'],
          'issue_number' : comics[i]['issue_number'],
          'cover_date' : months[formattedMonth]!+formattedYear,
          'api_url_volume' : comics[i]['volume']['api_detail_url'],
          'api_url_issue' :comics[i]['api_detail_url'],
        });
      }

      return comicsData;
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
        future: fetchAllComics(),
        builder: (context, comicsSnapshot) {
          if (comicsSnapshot.connectionState == ConnectionState.waiting) {
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
          } else if (comicsSnapshot.hasError) {
            return Center(child: Text('Error: ${comicsSnapshot.error}'));
          } else {
            List<Map<String, dynamic>> comics =
                comicsSnapshot.data as List<Map<String, dynamic>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 290,
                  padding: EdgeInsets.only(top : 32, left: 32),
                  child: Text(
                    'Comics les plus populaires',
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
                    itemCount: comics.length >= 50 ? 50 : comics.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      // Récupérer les données de la série à cet index
                      Map<String, dynamic> comicsData = comics[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsComicsPage (
                                url_volume: comicsData['api_url_volume'],
                                url_issue: comicsData['api_url_issue'],
                                comicsName: comicsData['name'],
                                comicNumber: comicsData['issue_number'],
                                coverDate: comicsData['cover_date'],
                                volumeName: comicsData['name_volume'],
                                imageUrl: comicsData['image'],
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
                                          comicsData['image'],
                                          width: 129,
                                          height: 163,
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
                                      comicsData['name_volume'],
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: 230,
                                    child:
                                        Text(
                                          comicsData['name'],
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                        ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'res/svg/ic_books_bicolor.svg',
                                        width: 14,
                                        height: 14,
                                        color: AppColors.textBottomBar,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'N°${comicsData['issue_number'].toString()}',
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
                                        '${comicsData['cover_date'].toString()}',
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
                          'res/svg/navbar_comics.svg',
                          width: 24.01,
                          height: 24.01,
                          color: AppColors.textBottomBarSelected,
                        ),
                        Text(
                          'Comics',
                          style:
                              TextStyle(color: AppColors.textBottomBarSelected),
                        ),
                      ],
                    ),
                  ),
                ],
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
