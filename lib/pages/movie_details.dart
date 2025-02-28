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
  var db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails(widget.movieId).then((data) {
      setState(() {
        movieDetails = data;
        isLoading = false;
      });
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





  // We cannot use that function in onPressed bcs it's async Future func
  Future<void> _updateMovieStatus(String userId) async {

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
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





  void _addFavoriteMovie(){}

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
                                //TODO: BUTON FAVORİLERE EKLEME BUTONUNA ŞART GETİRİLECEK
                              });
                            } else {
                              print("User ID not found!");
                            }
                          },
                          child: Icon(Icons.add_circle)),

                      //TODO: BUTON FAVORİLERE EKLEME BUTONUNA ŞART GETİRİLECEK
                      if( )
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Removes background
                              shadowColor: Colors.transparent, // Removes shadow
                              elevation: 0, // No elevation
                            ),
                            onPressed: _addFavoriteMovie,
                            child: Icon(Icons.favorite)
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
