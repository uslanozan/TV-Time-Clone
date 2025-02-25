import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget{
  final int selectedIndex ;
  final Function(int) onTap;

  const BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: Colors.yellow,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.live_tv_outlined),
          label: 'Diziler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.movie),
          label: 'Filmler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Keşfetmek',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );

  }
}

//TODO: Şimdilik iplement edemedim bakacağım