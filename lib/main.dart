import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tvtime/core/theme_manager.dart';
import 'package:tvtime/pages/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TV Time Clone', // Dil desteği olmadan sabit başlık
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeManager.themeMode,
            home: Login(),
          );
        },
      ),
    );

  }
}