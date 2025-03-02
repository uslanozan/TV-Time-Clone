import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'movie_details.dart';

class MoviesPage extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<MoviesPage> {

  List<Map<String, String>> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies(); // Automatically fetch data when the screen loads
    /* TODO: BURASININ ÇÖZÜLMESİ GEREK LİSTEDEN ÇIKARILDIĞINDA GÜNCELLENMİYOR
    setState(() {

    });
     */
  }

   //TODO: BU KULLANILACAK
  Future<void> fetchMovies() async {
    // SharedPreferences'tan userId al
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      print("Kullanıcı oturumu açık değil.");
      return;
    }

    try {
      // Kullanıcı belgesini Firestore'dan al
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection("User").doc(userId).get();

      if (!userSnapshot.exists) {
        print("Kullanıcı bulunamadı.");
        return;
      }

      // userSnapshot.data() nullable olduğu için önce güvenli şekilde map'e dönüştürüyoruz
      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      if (userData == null || !userData.containsKey("watchLaterMovie")) {
        print("watchLaterMovie alanı bulunamadı.");
        return;
      }

      List<dynamic> watchLaterMovie = userData["watchLaterMovie"];

      if (watchLaterMovie.isEmpty) {
        print("watchLaterMovie listesi boş.");
        return ;
      }

      // Firestore'dan sadece watchLaterMovie'de olan filmleri çek
      var snapshot = await FirebaseFirestore.instance
          .collection("Movie")
          .where(FieldPath.documentId, whereIn: watchLaterMovie)
          .get();

      setState(() {
        movies = snapshot.docs.map((doc) {
          return {
            "name": doc.id, // Document ID (Movie Name)
            "bannerURL": doc["bannerURL"]?.toString() ?? "", // Ensure bannerURL is a String
          };
        }).toList();
      });
    } catch (error) {
      print("Hata oluştu: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    //TODO: TabBar Kullan
    return DefaultTabController(
        length: 2,
        child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
              tabs:[
                Tab(child: const Text("İzleme Listesi", style: TextStyle(color: Colors.yellow),)),
                Tab(child: const Text("Yaklaşanlar", style: TextStyle(color: Colors.yellow),)),
              ]
          ),
        ),
          body: movies.isEmpty ?
          Container(
            alignment: Alignment.center,
            child: Text("İzleme Listesinde Hiç Film Yok",
              style: TextStyle(color: Colors.yellow),
            ),
          )
              :
          Padding(
            padding: const EdgeInsets.all(4.0), // Kenar boşlukları
            child: GridView.builder(
              itemCount: movies.length, // TODO: DB'den film sayısının çekilmesi lazım
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Her satırda 3 öğe
                crossAxisSpacing: 4, // Yatay boşluk
                mainAxisSpacing: 4, // Dikey boşluk
                childAspectRatio: 0.7, // Kartların yüksekliği
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          movieId: movies[index]["name"]!,
                          bannerURL: movies[index]["bannerURL"]!,),
                      ),
                    ).then((_) {  //TODO: DETAYLARA GİDİP GELİNCE GÜNCELLENMİYOR
                      setState(() {}); // Geri dönünce listeyi güncelle
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(movies[index]["bannerURL"]!), // Fetch from Firestore
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
    );
  }
}