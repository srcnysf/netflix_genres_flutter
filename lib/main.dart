import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:netflix_genres_flutter/models/genre.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Netflix Genres",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dio dio = Dio();
  TextEditingController textEditingController = TextEditingController();
  var genreList = [];
  var filteredGenreList = [];
  var showingGenreList = [];

  Future getGenres() async {
    var response = await dio.get(
        'https://raw.githubusercontent.com/f/netflix-data/main/genres.tr.json');
    setState(() {
      genreList = (json.decode(response.data) as List<dynamic>)
          .map((x) => Genre.fromJson(x as Map<String, dynamic>))
          .toList();
      showingGenreList = genreList;
    });
  }

  @override
  void initState() {
    if (mounted) getGenres();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Netflix Genres"),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              title: TextField(
                controller: textEditingController,
                decoration: InputDecoration(hintText: "Search Genres"),
                onChanged: (value) {
                  setState(() {
                    filteredGenreList = genreList
                        .where((element) => element.name
                            .trim()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();

                    if (textEditingController.text.isEmpty) {
                      showingGenreList = genreList;
                    } else {
                      showingGenreList = filteredGenreList;
                    }
                  });
                },
              ),
              trailing: Visibility(
                visible: textEditingController.text.isNotEmpty,
                child: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      showingGenreList = genreList;
                      textEditingController.clear();
                      filteredGenreList.clear();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: genreList.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: showingGenreList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            await launch(showingGenreList[index].url);
                          },
                          title: Text(showingGenreList[index].name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
