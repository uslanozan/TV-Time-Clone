import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'series_details.dart';


class SeriesPage extends StatefulWidget {
  @override
  _SeriesState createState() => _SeriesState();
}

class _SeriesState extends State<SeriesPage> {

  List<Map<String, String>> series = [];

  @override
  void initState() {
    super.initState();
    fetchSeries(); // Automatically fetch data when the screen loads
  }

  Future<void> fetchSeries() async {
    var snapshot = await FirebaseFirestore.instance.collection("Series").get();

    setState(() {
      series = snapshot.docs.map((doc) {
        return {
          "name": doc.id,  // Document ID (Series Name)
          "bannerURL": doc["bannerURL"]?.toString() ?? "", // Ensure bannerURL is a String
        };
      }).toList();
    });
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
          body: Padding(
            padding: const EdgeInsets.all(4.0), // Kenar boşlukları
            child: GridView.builder(
              itemCount: series.length, // TODO: DB'den dizi sayısının çekilmesi lazım
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
                        builder: (context) => SeriesDetailScreen(
                          seriesId: series[index]["name"]!,
                          bannerURL: series[index]["bannerURL"]!,),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(series[index]["bannerURL"]!), // Fetch from Firestore
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },

            ),
          ),
        ));

  }


}