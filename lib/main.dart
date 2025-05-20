import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchscorefront/screens/home_screen.dart';
import 'package:watchscorefront/screens/login_screen.dart';
import 'package:watchscorefront/screens/moviesRegister_screen.dart';
import 'package:watchscorefront/screens/profile_screen.dart';
import 'package:watchscorefront/screens/register_screen.dart';
import 'package:watchscorefront/screens/serieDetails_screen.dart';
import 'package:watchscorefront/screens/seriesList.dart';
import 'package:watchscorefront/screens/seriesRegister_screen.dart';
import 'package:watchscorefront/widgets/registerContent_screen.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final prefs = snapshot.data as SharedPreferences;
            final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

            return isLoggedIn ? const HomeScreen() : const LoginScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/series': (context) => const SeriesList(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return ProfileScreen(userData: userData);
        },
        '/serie-details': (context) => SerieDetailScreen(serie: {}),
        '/register-movie': (context) => const MoviesRegister(),
        '/register-serie': (context) => const SeriesRegister(),
        '/register-content': (context) => const RegisterContentScreen(),
      },
    );
  }
}
