import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme_manager.dart';

class User{
  final int followers;
  final int following;
  final int comment;
  final String username;
  final String backgroundURL;

  User(this.followers, this.following, this.username, this.backgroundURL, this.comment);
}

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>{
  List<Map<String, String>> favoriteSeries = [];
  List<Map<String, String>> favoriteMovies = [];
  List<Map<String, String>> watchedSeries = [];
  List<Map<String, String>> watchedMovies = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Veriyi yükle
  }

  Future<void> fetchData() async {
    List<Map<String, String>> seriesFav = await fetchFavoriteSeries();
    List<Map<String, String>> seriesWatched = await fetchWatchedSeries();
    List<Map<String, String>> moviesFav = await fetchFavoriteMovies();
    List<Map<String, String>> moviesWatched = await fetchWatchedMovies();
    setState(() {
      favoriteSeries = seriesFav; // State'i güncelle
      favoriteMovies = moviesFav; // State'i güncelle
      watchedSeries = seriesWatched; // State'i güncelle
      watchedMovies = moviesWatched; // State'i güncelle
    });
  }

  Future<List<Map<String, String>>> fetchWatchedSeries() async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("Kullanıcı oturumu açık değil.");
        return [];
      }

      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection("User").doc(userId).get();

      if (!userSnapshot.exists) {
        print("Kullanıcı bulunamadı.");
        return [];
      }

      List<dynamic>? watchedSeries = userSnapshot.get("watchedSeries");

      if (watchedSeries == null || watchedSeries.isEmpty) {
        print("Kullanıcının izlediği diziler bulunamadı.");
        return [];
      }

      // Favori olan dizileri filtrele
      List<String> favoriteSeriesIDs = watchedSeries
          .map<String>((series) => series["seriesID"].toString())
          .toList();

      if (favoriteSeriesIDs.isEmpty) {
        return [];
      }

      // Firestore'dan Series koleksiyonundaki bilgileri getir
      var snapshotSeries = await FirebaseFirestore.instance
          .collection("Series")
          .where(FieldPath.documentId, whereIn: favoriteSeriesIDs)
          .get();

      // Series verilerini uygun formata çevir
      List<Map<String, String>> seriesList = snapshotSeries.docs.map((doc) {
        return {
          "seriesID": doc.id,
          "bannerURL": doc["bannerURL"]?.toString() ?? ""
        };
      }).toList();

      print(seriesList);
      return seriesList;
    } catch (error) {
      print("Favori diziler çekilirken hata oluştu: $error");
      return [];
    }
  }

  Future<List<Map<String, String>>> fetchWatchedMovies() async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("Kullanıcı oturumu açık değil.");
        return [];
      }

      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection("User").doc(userId).get();

      if (!userSnapshot.exists) {
        print("Kullanıcı bulunamadı.");
        return [];
      }

      List<dynamic>? watchedMovies = userSnapshot.get("watchedMovies");

      if (watchedMovies == null || watchedMovies.isEmpty) {
        print("Kullanıcının izlediği filmler bulunamadı.");
        return [];
      }

      // Favori olan filmleri filtrele
      List<String> favoriteMoviesIDs = watchedMovies
          .where((movie) => movie["isFavorite"] == true)
          .map<String>((movie) => movie["movieID"].toString())
          .toList();

      if (favoriteMoviesIDs.isEmpty) {
        return [];
      }

      // Firestore'dan Movie koleksiyonundaki bilgileri getir
      var snapshotMovies = await FirebaseFirestore.instance
          .collection("Movie")
          .get();

      // Movie verilerini uygun formata çevir
      List<Map<String, String>> moviesList = snapshotMovies.docs.map((doc) {
        return {
          "moviesID": doc.id,
          "bannerURL": doc["bannerURL"]?.toString() ?? ""
        };
      }).toList();

      print(moviesList);
      return moviesList;
    } catch (error) {
      print("Favori filmler çekilirken hata oluştu: $error");
      return [];
    }

  }

  Future<List<Map<String, String>>> fetchFavoriteMovies() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("Kullanıcı oturumu açık değil.");
        return [];
      }

      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection("User").doc(userId).get();

      if (!userSnapshot.exists) {
        print("Kullanıcı bulunamadı.");
        return [];
      }

      List<dynamic>? watchedMovies = userSnapshot.get("watchedMovies");

      if (watchedMovies == null || watchedMovies.isEmpty) {
        print("Kullanıcının izlediği filmler bulunamadı.");
        return [];
      }

      // Favori olan filmleri filtrele
      List<String> favoriteMoviesIDs = watchedMovies
          .where((movie) => movie["isFavorite"] == true)
          .map<String>((movie) => movie["movieID"].toString())
          .toList();

      if (favoriteMoviesIDs.isEmpty) {
        return [];
      }

      // Firestore'dan Movie koleksiyonundaki bilgileri getir
      var snapshotMovies = await FirebaseFirestore.instance
          .collection("Movie")
          .where(FieldPath.documentId, whereIn: favoriteMoviesIDs)
          .get();

      // Movie verilerini uygun formata çevir
      List<Map<String, String>> moviesList = snapshotMovies.docs.map((doc) {
        return {
          "moviesID": doc.id,
          "bannerURL": doc["bannerURL"]?.toString() ?? ""
        };
      }).toList();

      print(moviesList);
      return moviesList;
    } catch (error) {
      print("Favori filmler çekilirken hata oluştu: $error");
      return [];
    }
  }

  Future<List<Map<String, String>>> fetchFavoriteSeries() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("Kullanıcı oturumu açık değil.");
        return [];
      }

      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection("User").doc(userId).get();

      if (!userSnapshot.exists) {
        print("Kullanıcı bulunamadı.");
        return [];
      }

      List<dynamic>? watchedSeries = userSnapshot.get("watchedSeries");

      if (watchedSeries == null || watchedSeries.isEmpty) {
        print("Kullanıcının izlediği diziler bulunamadı.");
        return [];
      }

      // Favori olan dizileri filtrele
      List<String> favoriteSeriesIDs = watchedSeries
          .where((series) => series["isFavorite"] == true)
          .map<String>((series) => series["seriesID"].toString())
          .toList();

      if (favoriteSeriesIDs.isEmpty) {
        return [];
      }

      // Firestore'dan Series koleksiyonundaki bilgileri getir
      var snapshotSeries = await FirebaseFirestore.instance
          .collection("Series")
          .where(FieldPath.documentId, whereIn: favoriteSeriesIDs)
          .get();

      // Series verilerini uygun formata çevir
      List<Map<String, String>> seriesList = snapshotSeries.docs.map((doc) {
        return {
          "seriesID": doc.id,
          "bannerURL": doc["bannerURL"]?.toString() ?? ""
        };
      }).toList();

      print(seriesList);
      return seriesList;
    } catch (error) {
      print("Favori diziler çekilirken hata oluştu: $error");
      return [];
    }
  }



  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    _editProfile(){}
    _showFavoriteSeries(){}
    _showFavoriteMovies(){}

    String mod = "Mod Ayarı";

    return SingleChildScrollView(
      child: Column(
        children: [

          Stack(
            alignment: Alignment.center, // Elemanları ortalamak için
            children: [
              // Arka Plan (Kapak Fotoğrafı)
              Container(
                height: 200, // Kapak fotoğrafının yüksekliği
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/scarface_background.jpg"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), // %50 şeffaflık ekler
                      BlendMode.darken, // Karanlık bir efekt verir
                    ),
                  ),
                ),
              ),

              // Profil Fotoğrafı ve Kullanıcı Bilgileri (Row içinde)
              Positioned(
                bottom: 4, // Profil fotoğrafını biraz aşağı kaydırdık
                left: 20, // Soldan boşluk ekledik
                right: 20, // Sağdan boşluk ekledik
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Elemanları sola hizaladık
                  children: [
                    // Profil Fotoğrafı
                    CircleAvatar(
                      radius: 33, // Profil fotoğrafının boyutu
                      backgroundColor: Colors.white, // Çerçeve efekti için
                      child: CircleAvatar(
                        radius: 30, // Gerçek profil fotoğrafı
                        backgroundImage: AssetImage("assets/images/homelander_profile_picture.png"),
                      ),
                    ),
                    const SizedBox(width: 10), // Profil ile Column arasında boşluk

                    // Kullanıcı Bilgileri (Username + Buton)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Sola hizalama
                      children: [
                        Text(
                          "USERNAME",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Profili düzenleme işlemi burada olacak
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20), // Buton iç padding azaltıldı
                            textStyle: TextStyle(fontSize: 14), // Buton metni küçültüldü
                          ),
                          child: const Text("Düzenle"),

                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              Column(
                children: [
                  Text("1"),
                  Text("Takip Edilenler"),
                ],
              ),
              SizedBox(width: 10,),
              Column(
                children: [
                  Text("2"),
                  Text("Takipçiler")
                ],
              ),
              SizedBox(width: 10,),
              Column(
                children: [
                  Text("3"),
                  Text("Yorum")
                ],
              ),

              SizedBox(height: 40),

              Wrap(
                //crossAxisAlignment: WrapCrossAlignment.start,
                //alignment: WrapAlignment.start,
                spacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(mod),
                      Material(
                        child: Switch(
                          value: themeManager.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeManager.toggleTheme();
                            setState(() {
                              mod = "Karanlık Mod";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          Container(
            alignment: Alignment.centerLeft, // Butonu sola hizalar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _showFavoriteSeries,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Buton boyutunu metin ve ikon kadar yapar
                    children: [
                      Text("İzlediğim Filmler"), // Metin
                      SizedBox(width: 5), // Metin ile ikon arasında boşluk
                      Icon(Icons.arrow_forward_ios), // İkon
                    ],
                  ),
                ),
                SizedBox(
                  height: 150, // ListView yüksekliği belirlenmeli
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: watchedMovies.length, // favoriteSeries.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 150, // Eleman genişliği
                        margin: EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(watchedMovies[index]['bannerURL']!), // Fetch from Firestore
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.centerLeft, // Butonu sola hizalar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _showFavoriteSeries,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Buton boyutunu metin ve ikon kadar yapar
                    children: [
                      Text("Favori Filmler"), // Metin
                      SizedBox(width: 5), // Metin ile ikon arasında boşluk
                      Icon(Icons.arrow_forward_ios), // İkon
                    ],
                  ),
                ),
                SizedBox(
                  height: 150, // ListView yüksekliği belirlenmeli
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteMovies.length, // favoriteSeries.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 150, // Eleman genişliği
                        margin: EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(favoriteMovies[index]['bannerURL']!), // Fetch from Firestore
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30,),

          Container(
            alignment: Alignment.centerLeft, // Butonu sola hizalar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _showFavoriteSeries,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Buton boyutunu metin ve ikon kadar yapar
                    children: [
                      Text("İzlediğim Diziler"), // Metin
                      SizedBox(width: 5), // Metin ile ikon arasında boşluk
                      Icon(Icons.arrow_forward_ios), // İkon
                    ],
                  ),
                ),
                SizedBox(
                  height: 150, // ListView yüksekliği belirlenmeli
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: watchedSeries.length, // favoriteSeries.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 150, // Eleman genişliği
                        margin: EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(watchedSeries[index]['bannerURL']!), // Fetch from Firestore
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

      Container(
        alignment: Alignment.centerLeft, // Butonu sola hizalar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _showFavoriteSeries,
              child: Row(
                mainAxisSize: MainAxisSize.min, // Buton boyutunu metin ve ikon kadar yapar
                children: [
                  Text("Favori Diziler"), // Metin
                  SizedBox(width: 5), // Metin ile ikon arasında boşluk
                  Icon(Icons.arrow_forward_ios), // İkon
                ],
              ),
            ),
            SizedBox(
              height: 150, // ListView yüksekliği belirlenmeli
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favoriteSeries.length, // favoriteSeries.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150, // Eleman genişliği
                    margin: EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(favoriteSeries[index]['bannerURL']!), // Fetch from Firestore
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
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
