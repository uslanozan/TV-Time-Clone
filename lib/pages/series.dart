import 'dart:ffi';

import 'package:flutter/material.dart';

class Movie{
  final String movieName;
  final double imdb;
  final String bannerURL;
  final ElevatedButton buttonWatched;
  final bool isWatched;
  final String movieExplanation;

  Movie({required this.movieName, required this.imdb, required this.bannerURL
    ,required this.buttonWatched, required this.isWatched, required this.movieExplanation});
}

class SeriesPage extends StatefulWidget {
  @override
  _SeriesState createState() => _SeriesState();
}

class _SeriesState extends State<SeriesPage> {

  //TODO: Filmler Database'den gelecek ve film objesi olarak gelecek
  List<Movie> watchedMovies = [

  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("İzlediğim Diziler")),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10
          ),
          itemCount: watchedMovies.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (context, index){
            return Container(
              decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(10)
              ),
            );
          },
        )
    );
  }


}
