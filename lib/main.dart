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
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final userData = snapshot.data as Map<String, dynamic>;
              return HomeScreen(userData: userData);
            }
            return const LoginScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      onGenerateRoute: (settings) {
        final userData = settings.arguments as Map<String, dynamic>? ?? {};

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            return MaterialPageRoute(
              builder: (_) => HomeScreen(userData: userData),
            );
          case '/series':
            return MaterialPageRoute(
              builder: (_) => SeriesList(userData: userData),
            );
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => ProfileScreen(userData: userData),
            );
          case '/serie-details':
            return MaterialPageRoute(
              builder:
                  (_) => SerieDetailScreen(
                    serie: settings.arguments as Map<String, dynamic>,
                    userData: userData,
                  ),
            );
          case '/register-movie':
            return MaterialPageRoute(
              builder: (_) => MoviesRegister(userData: userData),
            );
          case '/register-serie':
            return MaterialPageRoute(
              builder: (_) => SeriesRegister(userData: userData),
            );
          case '/register-content':
            return MaterialPageRoute(
              builder: (_) => RegisterContentScreen(userData: userData),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => HomeScreen(userData: userData),
            );
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      return {
        'identificacion': prefs.getInt('userId'),
        'email': prefs.getString('userEmail'),
        'nombre': prefs.getString('userName'),
        'apellido': prefs.getString('userLastName'),
        'celular': prefs.getString('userPhone'),
        'ciudad': prefs.getString('userCity'),
        'fechaNacimiento': prefs.getString('userBirthDate'),
      };
    }
    return null;
  }
}
