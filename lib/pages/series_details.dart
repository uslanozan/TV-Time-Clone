import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeriesDetailScreen extends StatefulWidget {
  final String seriesId;
  final String bannerURL;

  SeriesDetailScreen({required this.seriesId, required this.bannerURL});

  @override
  _SeriesDetailScreenState createState() => _SeriesDetailScreenState();
}

Future<Map<String, dynamic>> fetchSeriesDetails(String seriesId) async {
  var docSnapshot =
  await FirebaseFirestore.instance.collection("Series").doc(seriesId).get();

  if (docSnapshot.exists) {
    Map<String, dynamic> seriesData = docSnapshot.data()!;

    // Remove 'bannerURL' before returning
    seriesData.remove("bannerURL");

    return seriesData;
  } else {
    throw Exception("Document does not exist!");
  }
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  Map<String, dynamic>? seriesDetails;
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
    fetchSeriesDetails(widget.seriesId).then((data) {
      setState(() {
        seriesDetails = data;
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
    "seriesName": "Series Name",
    "star": "Star",
    "startYear": "Publish Year",
    "endYear": "Finish Year",
    "explanation": "Description of Series",
    "imdb": "IMDb"
  };

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  Future<bool> _checkIsWatched(String userId) async {

    String seriesId = widget.seriesId;
    try {
      // Get user document
      var userDoc = await FirebaseFirestore.instance.collection("User").doc(userId).get();

      // Check if the document exists
      if (!userDoc.exists) {
        print("Error: User document does not exist!");
        return false;
      }

      // Retrieve the watchedSeries array
      List<dynamic> watchedSeries = userDoc.data()?["watchedSeries"] ?? [];

      // Check if the seriesId exists in watchedSeries
      bool isWatched = watchedSeries.any((series) => series["seriesID"] == seriesId);

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
      List<dynamic> watchLaterSeries = userDoc.data()?["watchLaterSeries"] ?? [];

      bool isSeriesInList = watchLaterSeries.contains(widget.seriesId);

      setState(() {
        if (isSeriesInList) {
          defaultAddLaterText = "İzleme Listesinden Çıkar";
          defaultAddLaterList = Colors.red;
        } else {
          defaultAddLaterText = "İzleme Listesine Ekle";
          defaultAddLaterList = Colors.yellow;
        }
      });

      print("Initial check completed. Series in list: $isSeriesInList");
    } catch (e) {
      print("Error checking Watch Later status: $e");
    }
  }

  Future<void> _addWatchLaterSeriesList() async {
    print("DENEMEEE EKLENDİİ");
    String? userId = await getUserId();
    if (userId == null) return;

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();

      // Firestore'dan gelen listeyi "List<String>" olarak al
      List<dynamic> watchLaterSeriesDynamic = userDoc.data()?["watchLaterSeries"] ?? [];
      List<String> watchLaterSeries = List<String>.from(watchLaterSeriesDynamic);

      // Eğer dizi zaten varsa ekleme
      if (watchLaterSeries.contains(widget.seriesId)) {
        print("Series is already in Watch Later!");
        return;
      }

      // dizi yoksa listeye ekle
      watchLaterSeries.add(widget.seriesId);

      // Firestore'daki watchLaterSeries dizisini güncelle
      await userRef.update({
        "watchLaterSeries": watchLaterSeries,
      });

      setState(() {
        isFavorite = true;
      });

      print("Series added to Watch Later successfully!");
    } catch (e) {
      print("❌ Error adding series to Watch Later: $e");
    }
  }

  Future<bool> _checkIsFavorite(String userId) async {
    var seriesId = widget.seriesId;
    try {

      bool isWatched = await _checkIsWatched(userId);

      if (!isWatched) return false; // If the series isn't watched, it can't be a favorite

      var userDoc = await FirebaseFirestore.instance.collection("User").doc(userId).get();

      List<dynamic> watchedSeries = userDoc.data()?["watchedSeries"] ?? [];

      for (var series in watchedSeries) {
        if (series["seriesID"] == seriesId) {
          return series["isFavorite"] ?? false; // Return isFavorite value
        }
      }

      return false;
    } catch (e) {
      print("Error checking favorite status: $e");
      return false;
    }
  }

  Future<void> _removeWatchLaterSeriesList(String userId) async {
    String? userId = await getUserId();
    if (userId == null) {
      print("User ID not found!");
      return;
    }

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();
      List<dynamic> watchLaterSeries = userDoc.data()?["watchLaterSeries"] ?? [];

      if (watchLaterSeries.contains(widget.seriesId)) {
        watchLaterSeries.remove(widget.seriesId);
        await userRef.update({
          "watchLaterSeries": watchLaterSeries,
        });

        print("Series removed from Watch Later list.");
      } else {
        print("Series is not in the Watch Later list!");
      }
    } catch (e) {
      print("Error removing series from Watch Later: $e");
    }
  }

  Future<void> _removeSeriesFromWatched(String userId) async {
    print("DENEMEEE ÇIKARILDI");
    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      bool isWatched = await _checkIsWatched(userId);

      if (!isWatched) {
        print("Series is not in the watched list!");
        return;
      }

      // Kullanıcının mevcut izlediği dizileri al
      var userDoc = await userRef.get();
      List<dynamic> watchedSeries = userDoc.data()?["watchedSeries"] ?? [];

      // Kaldırılacak diziyi filtrele
      watchedSeries.removeWhere((series) => series["seriesID"] == widget.seriesId);

      // Güncellenmiş listeyi tekrar Firestore'a kaydet
      await userRef.update({
        "watchedSeries": watchedSeries,
      });

      print("Series removed from watched list successfully!");
    } catch (e) {
      print("Error removing Series: $e");
    }
  }


  // We cannot use that function in onPressed bcs it's async Future func
  Future<void> _updateSeriesStatus(String userId) async {
    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      bool isWatched = await _checkIsWatched(userId);

      if (isWatched) {
        print("Series is already watched!");
        return;
      }

      await userRef.update({
        "watchedSeries": FieldValue.arrayUnion([
          {"isFavorite": false, "seriesID": widget.seriesId}
        ])
      });

      print("Series added successfully!");
    } catch (e) {
      print("Error adding series: $e");
    }
  }


  void _addFavoriteSeries() async {
    String? userId = await getUserId();
    if (userId == null) return;

    bool isWatched = await _checkIsWatched(userId);
    if (!isWatched) {
      print("Error: Series must be watched before adding to favorites!");
      return;
    }

    var userRef = FirebaseFirestore.instance.collection("User").doc(userId);

    try {
      var userDoc = await userRef.get();
      List<dynamic> watchedSeries = userDoc.data()?["watchedSeries"] ?? [];

      for (var series in watchedSeries) {
        if (series["seriesID"] == widget.seriesId) {
          if (series["isFavorite"] == true) {
            print("Series is already in favorites!");
            return;
          }
          series["isFavorite"] = true; // Favoriye ekle
        }
      }

      // Firestore'daki watchedSeries dizisini güncelle
      await userRef.update({
        "watchedSeries": watchedSeries,
      });

      setState(() {
        isFavorite = true; // UI'ı güncelle
      });

      print("Series added to favorites successfully!");
    } catch (e) {
      print("Error adding favorite series: $e");
    }
  }


  //var bool isFavoriteButtonShowing;
  //if(_checkIsWatched )

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Series Details",
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
                        await _updateSeriesStatus(userId);
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
                    onPressed: _addFavoriteSeries,
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
                        await _removeSeriesFromWatched(userId);
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
                      List<dynamic> watchLaterSeries = userDoc.data()?["watchLaterSeries"] ?? [];

                      if (watchLaterSeries.contains(widget.seriesId)) {
                        await _removeWatchLaterSeriesList(userId);
                        setState(() {
                          defaultAddLaterText = "İzleme Listesine Ekle";
                          defaultAddLaterList = Colors.yellow;
                        });
                      } else {
                        await _addWatchLaterSeriesList();
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

            ...seriesDetails!.entries.map((entry) {
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
