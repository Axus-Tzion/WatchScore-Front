import 'package:flutter/material.dart';

class PersonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> person;
  final String type; // Puede ser 'Actor' o 'Director'

  const PersonDetailScreen({
    super.key,
    required this.person,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final String nombre = person['nombre'] ?? 'Nombre desconocido';
    final String fechaNacimiento =
        person['fechaNacimiento'] ?? 'Fecha desconocida';
    final String nacionalidad =
        person['nacionalidad'] ?? 'Nacionalidad desconocida';
    final String biografia =
        person['biografia'] ?? 'No hay biografía disponible';

    return Scaffold(
      appBar: AppBar(
        title: Text('$type: $nombre'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple[100],
                child: Icon(
                  type == 'Actor' ? Icons.person : Icons.movie_creation,
                  size: 50,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              nombre,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha de nacimiento: $fechaNacimiento',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Nacionalidad: $nacionalidad',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Biografía',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(biografia, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
