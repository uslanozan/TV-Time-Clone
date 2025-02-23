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

class MoviesPage extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<MoviesPage> {

  //TODO: Filmler Database'den gelecek ve film objesi olarak gelecek
  List<Movie> watchedMovies = [

  ];


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0), // Kenar boşlukları
      child: GridView.builder(
        itemCount: 21, // TODO: DB'den film sayısının çekilmesi lazım
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Her satırda 3 öğe
          crossAxisSpacing: 4, // Yatay boşluk
          mainAxisSpacing: 4, // Dikey boşluk
          childAspectRatio: 0.7, // Kartların yüksekliği
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/recep.jpg"), // Doğru kullanım
                fit: BoxFit.cover,
              ),
            ),

          );
        },
      ),
    );
  }

/*
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
  */
}
