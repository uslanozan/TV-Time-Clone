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
  String title = "Anasayfa";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

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
          switch(index){
            case 0:
              title = "Anasayfa";
              break;
            case 1:
              title = "Profil";
              break;
            case 2:
              title = "Arama";
              break;
          }
          setState(() {

          });
        } ,
      ),
    );
  }
}

