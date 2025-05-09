import 'package:flutter/material.dart';
import 'package:watchscorefront/screens/moviesRegister_screen.dart';
import 'package:watchscorefront/screens/seriesRegister_screen.dart';

class RegisterContentScreen extends StatelessWidget {
  const RegisterContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Contenido'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoviesRegister(),
                  ),
                );
              },
              child: const Text('Registrar Película'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SeriesRegister(),
                  ),
                );
              },
              child: const Text('Registrar Serie'),
            ),
          ],
        ),
      ),
    );
  }
}
