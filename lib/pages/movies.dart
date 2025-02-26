import 'package:flutter/material.dart';

class Movie{
  final String movieName;
  final double imdb;
  final String bannerURL;
  final ElevatedButton buttonWatched;
  final String movieExplanation;
  final String star;
  final int year;

  Movie(this.movieName, this.imdb, this.bannerURL, this.buttonWatched,
      this.movieExplanation, this.star, this.year);
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
    //TODO: TabBar Kullan
    return DefaultTabController(
        length: 2,
        child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
              tabs:[
                Tab(child: const Text("İzleme Listesi")),
                Tab(child: const Text("Yaklaşanlar")),
              ]
          ),
        ),
          body: Padding(
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
          ),
        ));

    /*
    //TODO: Topbar olmayan hali
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
     */
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
