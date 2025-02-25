import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget{
  final int selectedIndex ;
  final Function(int) onTap;

  const BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        bottom: const TabBar(
            tabs:[
              Tab(child: const Text("İzleme Listesi")),
              Tab(child: const Text("Yaklaşanlar")),
            ]
        ),
      ),
      ),
    );

  }
}

//TODO: Şimdilik iplement edemedim bakacağım