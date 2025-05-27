import 'package:flutter/material.dart';
import 'package:watchscorefront/screens/actorRegister_screen.dart';
import 'package:watchscorefront/screens/directorRegister_screen.dart';
import 'package:watchscorefront/screens/moviesRegister_screen.dart';
import 'package:watchscorefront/screens/seriesRegister_screen.dart';

class RegisterContentScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const RegisterContentScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Registrar Contenido'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Icon(
                Icons.video_library,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Qué deseas registrar?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildButton(
                context,
                label: 'Registrar Película',
                screen: MoviesRegister(userData: userData),
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                label: 'Registrar Serie',
                screen: SeriesRegister(userData: userData),
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                label: 'Registrar Actor',
                screen: const ActorRegister(),
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                label: 'Registrar Director',
                screen: const DirectorRegister(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(label),
      ),
    );
  }
}
