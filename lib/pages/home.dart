import 'package:flutter/material.dart';
import 'package:tvtime/pages/movies.dart';
import 'package:tvtime/pages/profile.dart';
import 'package:tvtime/pages/search.dart';
import 'package:tvtime/pages/series.dart';
import 'package:tvtime/widget/navbar_bottom.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState() ;
}

class _HomePageState extends State<HomePage>{
  int _selectedIndex = 0;
  //String title = "Anasayfa";


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SeriesPage(),
          MoviesPage(),
          SearchPage(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (int index) {
          _selectedIndex = index;
          /* Title kaldırıldı
          switch(index){
            case 0:
              title = "Diziler";
              break;
            case 1:
              title = "Filmler";
              break;
            case 2:
              title = "Arama";
              break;
            case 3:
              title = "Profil";
              break;
          }
           */
          setState(() {

          });
        } ,
      ),
    );
  }
}

