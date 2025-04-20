import 'package:flutter/material.dart';
import 'package:watchscorefront/screens/login_screen.dart';
import 'package:watchscorefront/screens/moviesRegister_screen.dart';
import 'package:watchscorefront/screens/seriesRegister_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WatchScore',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple[50],
      ),
      home: SeriesRegister(),
    );
  }
}
