import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    /* TODO: BURASININ ÇÖZÜLMESİ GEREK LİSTEDEN ÇIKARILDIĞINDA GÜNCELLENMİYOR
    setState(() {

    });
     */
  }

  Future<void> fetchSeries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if(userId==null){
      print("Kullanıcı oturumu açık değil");
      return;
    }

    try{
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection("User").doc(userId).get();

      if(!userSnapshot.exists){
        print("Kullanıcı bulunamadı");
        return;
      }

      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if(userData == null || !userData.containsKey("watchLaterSeries")){
        print("watchLaterSeries alanı bulunamadı");
        return;
      }

      List<dynamic> watchLaterSeries = userData["watchLaterSeries"];

      if(watchLaterSeries.isEmpty){
        print("watchLaterSeries listesi boş");
        return;
      }

      var snapshot = await FirebaseFirestore.instance
      .collection("Series")
      .where(FieldPath.documentId, whereIn: watchLaterSeries)
      .get();

      setState(() {
        series = snapshot.docs.map((doc) {
          return {
            "name": doc.id,  // Document ID (Series Name)
            "bannerURL": doc["bannerURL"]?.toString() ?? "", // Ensure bannerURL is a String
          };
        }).toList();
      });

    }catch (error){
      print("Hata oluştu: $error");
    }

    /*

     */
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
          body: series.isEmpty ?
              Container(
                alignment: Alignment.center,
                child: Text("İzleme Listesinde Hiç Dizi Yok",
                  style: TextStyle(color: Colors.yellow),
                ),
              )
              :
          Padding(
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
                    ).then((_) {//TODO: DETAYLARA GİDİP GELİNCE GÜNCELLENMİYOR
                      setState(() {}); // Geri dönünce listeyi güncelle
                    });
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