
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme_manager.dart';

class Profile extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    String mod = "Mod Ayarı";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(mod),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (value){
                themeManager.toggleTheme();
                //TODO: Stateful widget yapıp text'i değiştir.
                mod = "Karanlık Mod";
              },
            ),
          ],
        ),
      ],
    );
  }
}