import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'films_details.dart';

import 'main.dart';

class CharacterDetailsPage extends StatefulWidget {
  static const String apiKey = '9f0bb9bce7f9154f43645e7d6cb131a10fe20346';
  final String characterName;
  final String imageUrl;
  final String Histoire;
  final String nomHeros;
  final String nomReel;
  final String alias;
  final int genre;
  final String dateNaissance;
  final String dateDeces;
  List<Map<String, dynamic>> publishersData = [];
  List<Map<String, dynamic>> creatorsData = [];

  CharacterDetailsPage({
    required this.characterName,
    required this.imageUrl,
    required this.Histoire,
    required this.nomHeros,
    required this.nomReel,
    required this.alias,
    required this.genre,
    required this.dateNaissance,
    required this.dateDeces,
    required this.creatorsData,
    required this.publishersData,
  });

  @override
  CharacterDetailsPageState createState() => CharacterDetailsPageState();
}

class CharacterDetailsPageState extends State<CharacterDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController2;

  @override
  void initState() {
    super.initState();
    _tabController2 = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.characterName,
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
                TabBar(
                  dividerColor: Colors.transparent,
                  controller: _tabController2,
                  tabs: [
                    Tab(text: 'Histoire'),
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
                      controller: _tabController2,
                      children: [
                        SingleChildScrollView(
                            child: Text(
                              '${extractDescription(widget.Histoire)}',
                              style: TextStyle(color: Colors.white, fontSize: 17),
                            )),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              InfosTab(
                                  nomHeros: widget.nomHeros,
                                  nomReel: widget.nomReel,
                                  alias: widget.alias,
                                  publishersData: widget.publishersData,
                                  creatorsData: widget.creatorsData,
                                  genre: widget.genre,
                                  dateNaissance: widget.dateNaissance,
                                  dateDeces: widget.dateDeces)
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

String extractDescription(String htmlDescription) {
  final document = parse(htmlDescription);
  final paragraphs = document.querySelectorAll('p');
  final List<String> descriptions =
  paragraphs.map((element) => element.text).toList();
  return descriptions.join('\n');
}

class InfosTab extends StatelessWidget {
  final String? nomHeros;
  final String? nomReel;
  final String? alias;
  List<Map<String, dynamic>> publishersData = [];
  List<Map<String, dynamic>> creatorsData = [];
  final int? genre;
  final String? dateNaissance;
  final String? dateDeces;

  InfosTab({
    required this.nomHeros,
    required this.nomReel,
    required this.alias,
    required this.publishersData,
    required this.creatorsData,
    required this.genre,
    required this.dateNaissance,
    required this.dateDeces,
  });

  String IntToStringGenre(int nb) {
    switch (nb) {
      case 2:
        {
          return "Féminin";
        }
      case 1:
        {
          return "Masculin";
        }
      default:
        {
          return "Inconnu";
        }
    }
  }

  Widget _buildAliasItem(String alias) {
    final List<String> aliases = alias.split('\n');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '   Alias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: aliases
                .map((alias) => Align(
              alignment: Alignment.centerRight,
              child: Text(
                alias + "     ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem('Nom de super-Héros', nomHeros!),
          _buildInfoItem('Nom réel', nomReel!),
          _buildAliasItem(alias!),
          _buildInfoItem('Editeurs', publishersData[0]['name']),
          _buildListInfoItem('Créateurs', creatorsData),
          _buildInfoItem('Genre', IntToStringGenre(genre!)),
          _buildInfoItem('Date de naissance', dateNaissance!),
          _buildInfoItem('Décès', dateDeces!),
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
