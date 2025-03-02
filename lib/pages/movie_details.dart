import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;
  final String bannerURL;

  MovieDetailScreen({required this.movieId, required this.bannerURL});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

Future<Map<String, dynamic>> fetchMovieDetails(String movieId) async {
  var docSnapshot =
      await FirebaseFirestore.instance.collection("Movie").doc(movieId).get();

  if (docSnapshot.exists) {
    Map<String, dynamic> movieData = docSnapshot.data()!;

    // Remove 'bannerURL' before returning
    movieData.remove("bannerURL");

    return movieData;
  } else {
    throw Exception("Document does not exist!");
  }
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movieDetails;
  bool isLoading = true;
  bool isFavorite = false;
  Color defaultAddButtonColor = Colors.yellow;
  Color defaultDeleteButtonColor = Colors.yellow;
  Color defaultAddLaterList = Colors.yellow;
  String defaultAddLaterText = "İzleme Listesine Ekle";
  var db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkIsAddWatchLater();
    fetchMovieDetails(widget.movieId).then((data) {
      setState(() {
        movieDetails = data;
        isLoading = false;
      });
    });

    getUserId().then((userId) {
      if (userId != null) {
        _checkIsFavorite(userId).then((favoriteStatus) {
          setState(() {
            isFavorite = favoriteStatus;
          });
        });
      }
    });
  }





  Map<String, String> fieldTitles = {
    "movieName": "Movie Name",
    "star": "Star",
    "year": "Publish Year",
    "explanation": "Description of Movie",
    "imdb": "IMDb"
  };

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  Future<bool> _checkIsWatched(String userId) async {

    String movieId = widget.movieId;
    try {
      // Get user document
      var userDoc = await FirebaseFirestore.instance.collection("User").doc(userId).get();

      // Check if the document exists
      if (!userDoc.exists) {
        print("Error: User document does not exist!");
        return false;
      }

      // Retrieve the watchedMovies array
      List<dynamic> watchedMovies = userDoc.data()?["watchedMovies"] ?? [];

      // Check if the movieId exists in watchedMovies
      bool isWatched = watchedMovies.any((movie) => movie["movieID"] == movieId);

      return isWatched;
    } catch (e) {
      print("Error checking watched status: $e");
      return false;
    }
  }

  void _checkIsAddWatchLater() async {
    String? userId = await getUserId();
    if (userId == null) return;

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();
      List<dynamic> watchLaterMovies = userDoc.data()?["watchLaterMovie"] ?? [];

      bool isMovieInList = watchLaterMovies.contains(widget.movieId);

      setState(() {
        if (isMovieInList) {
          defaultAddLaterText = "İzleme Listesinden Çıkar";
          defaultAddLaterList = Colors.red;
        } else {
          defaultAddLaterText = "İzleme Listesine Ekle";
          defaultAddLaterList = Colors.yellow;
        }
      });

      print("Initial check completed. Movie in list: $isMovieInList");
    } catch (e) {
      print("Error checking Watch Later status: $e");
    }
  }



  Future<bool> _checkIsFavorite(String userId) async {
    var movieId = widget.movieId;
    try {

      bool isWatched = await _checkIsWatched(userId);

      if (!isWatched) return false; // If the movie isn't watched, it can't be a favorite

      var userDoc = await FirebaseFirestore.instance.collection("User").doc(userId).get();

      List<dynamic> watchedMovies = userDoc.data()?["watchedMovies"] ?? [];

      for (var movie in watchedMovies) {
        if (movie["movieID"] == movieId) {
          return movie["isFavorite"] ?? false; // Return isFavorite value
        }
      }

      return false;
    } catch (e) {
      print("Error checking favorite status: $e");
      return false;
    }
  }

  Future<void> _removeMovieFromWatched(String userId) async {
    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      bool isWatched = await _checkIsWatched(userId);

      if (!isWatched) {
        print("Movie is not in the watched list!");
        return;
      }

      // Kullanıcının mevcut izlediği filmleri al
      var userDoc = await userRef.get();
      List<dynamic> watchedMovies = userDoc.data()?["watchedMovies"] ?? [];

      // Kaldırılacak filmi filtrele
      watchedMovies.removeWhere((movie) => movie["movieID"] == widget.movieId);

      // Güncellenmiş listeyi tekrar Firestore'a kaydet
      await userRef.update({
        "watchedMovies": watchedMovies,
      });

      print("Movie removed from watched list successfully!");
    } catch (e) {
      print("Error removing movie: $e");
    }
  }




  // We cannot use that function in onPressed bcs it's async Future func
  Future<void> _updateMovieStatus(String userId) async {
    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      bool isWatched = await _checkIsWatched(userId);

      if (isWatched) {
        print("Movie is already watched!");
        return;
      }

      await userRef.update({
        "watchedMovies": FieldValue.arrayUnion([
          {"isFavorite": false, "movieID": widget.movieId}
        ])
      });

      print("Movie added successfully!");
    } catch (e) {
      print("Error adding movie: $e");
    }
  }


  Future<void> _addWatchLaterMovieList() async {
    String? userId = await getUserId();
    if (userId == null) return;

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();

      // Firestore'dan gelen listeyi "List<String>" olarak al
      List<dynamic> watchLaterMoviesDynamic = userDoc.data()?["watchLaterMovie"] ?? [];
      List<String> watchLaterMovies = List<String>.from(watchLaterMoviesDynamic);

      // Eğer film zaten varsa ekleme
      if (watchLaterMovies.contains(widget.movieId)) {
        print("Movie is already in Watch Later!");
        return;
      }

      // Film yoksa listeye ekle
      watchLaterMovies.add(widget.movieId);

      // Firestore'daki watchLaterMovie dizisini güncelle
      await userRef.update({
        "watchLaterMovie": watchLaterMovies,
      });

      setState(() {
        isFavorite = true;
      });

      print("Movie added to Watch Later successfully!");
    } catch (e) {
      print("❌ Error adding movie to Watch Later: $e");
    }
  }


  Future<void> _removeWatchLaterMovieList() async {
    String? userId = await getUserId();
    if (userId == null) {
      print("User ID not found!");
      return;
    }

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();
      List<dynamic> watchLaterMovies = userDoc.data()?["watchLaterMovie"] ?? [];

      if (watchLaterMovies.contains(widget.movieId)) {
        watchLaterMovies.remove(widget.movieId);
        await userRef.update({
          "watchLaterMovie": watchLaterMovies,
        });

        print("Movie removed from Watch Later list.");
      } else {
        print("Movie is not in the Watch Later list!");
      }
    } catch (e) {
      print("Error removing movie from Watch Later: $e");
    }
  }





  void _addFavoriteMovie() async {
    String? userId = await getUserId();
    if (userId == null) return;

    bool isWatched = await _checkIsWatched(userId);
    if (!isWatched) {
      print("Error: Movie must be watched before adding to favorites!");
      return;
    }

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();
      List<dynamic> watchedMovies = userDoc.data()?["watchedMovies"] ?? [];

      for (var movie in watchedMovies) {
        if (movie["movieID"] == widget.movieId) {
          if (movie["isFavorite"] == true) {
            print("Movie is already in favorites!");
            return;
          }
          movie["isFavorite"] = true; // Favoriye ekle
        }
      }

      // Firestore'daki watchedMovies dizisini güncelle
      await userRef.update({
        "watchedMovies": watchedMovies,
      });

      setState(() {
        isFavorite = true; // UI'ı güncelle
      });

      print("Movie added to favorites successfully!");
    } catch (e) {
      print("Error adding favorite movie: $e");
    }
  }


  //var bool isFavoriteButtonShowing;
  //if(_checkIsWatched )

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Movie Details",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Loading indicator
            : Column(
                children: [
                  Image.network(widget.bannerURL), // Still displaying the image
                  SizedBox(height: 10),
                  Row(

                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Removes background
                            shadowColor: Colors.transparent, // Removes shadow
                            elevation: 0, // No elevation
                          ),
                          onPressed: () async {
                            String? userId = await getUserId();
                            if (userId != null) {
                              await _updateMovieStatus(userId);
                              setState(() {
                              });
                            } else {
                              print("User ID not found!");
                            }
                          },
                          child: Icon(Icons.add_circle,color: defaultAddButtonColor)),

                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Removes background
                              shadowColor: Colors.transparent, // Removes shadow
                              elevation: 0, // No elevation
                            ),
                            onPressed: _addFavoriteMovie,
                            child: Icon(Icons.favorite,
                              color: isFavorite ? Colors.red : Colors.yellow,)
                        ),

                      // Silme butonu
                      ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Removes background
                              shadowColor: Colors.transparent, // Removes shadow
                              elevation: 0, // No elevation
                            ),
                            onPressed: () async {
                              String? userId = await getUserId();
                              if (userId != null) {
                                await _removeMovieFromWatched(userId);
                                //TODO: ÇALIŞMIYOR
                                setState(() {
                                  defaultDeleteButtonColor = Colors.red;
                                  isFavorite = false;
                                });

                                // Belirli bir süre sonra tekrar sarıya döndür
                                Future.delayed(Duration(milliseconds: 300), () {
                                  setState(() {
                                    defaultDeleteButtonColor = Colors.yellow;
                                  });
                                });
                              } else {
                                print("User ID not found!");
                              }
                            },
                            child: Icon(Icons.delete,
                              color: defaultDeleteButtonColor)
                        ),

                      Expanded(
                          child: // İzleme listesi ekle/çıkar butonu
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Removes background
                              shadowColor: Colors.transparent, // Removes shadow
                              elevation: 0, // No elevation
                            ),
                            onPressed: () async {
                              String? userId = await getUserId();
                              if (userId == null) {
                                print("User ID not found!");
                                return;
                              }

                              var userRef = FirebaseFirestore.instance.collection("User").doc(userId);
                              var userDoc = await userRef.get();
                              List<dynamic> watchLaterMovies = userDoc.data()?["watchLaterMovie"] ?? [];

                              if (watchLaterMovies.contains(widget.movieId)) {
                                await _removeWatchLaterMovieList();
                                setState(() {
                                  defaultAddLaterText = "İzleme Listesine Ekle";
                                  defaultAddLaterList = Colors.yellow;
                                });
                              } else {
                                await _addWatchLaterMovieList();
                                setState(() {
                                  defaultAddLaterText = "İzleme Listesinden Çıkar";
                                  defaultAddLaterList = Colors.red;
                                });
                              }

                              // 300ms sonra tekrar sarıya döndür
                              Future.delayed(Duration(milliseconds: 300), () {
                                setState(() {
                                  defaultAddLaterList = Colors.yellow;
                                });
                              });
                            },

                            child: Text(
                              defaultAddLaterText,
                              style: TextStyle(color: defaultAddLaterList),
                              softWrap: true, // Metnin aşağıya devam etmesini sağlar
                              overflow: TextOverflow.visible, // Overflow'u görünür yapar
                              maxLines: null, // Satır sınırını kaldırır
                            ),
                          ),
                      ),
                    ],
                  ),

                  ...movieDetails!.entries.map((entry) {
                    String title = fieldTitles[entry.key] ??
                        entry.key; // Use custom title or fallback
                    String value =
                        entry.value.toString(); // Convert int to String

                    return ListTile(
                      title: Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow)),
                      subtitle: Text(
                          value), // Ensures int values are displayed properly
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
