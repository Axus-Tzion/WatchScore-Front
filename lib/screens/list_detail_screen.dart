import 'package:flutter/material.dart';

class ListDetailScreen extends StatelessWidget {
  final dynamic lista;

  const ListDetailScreen({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lista['nombre'] ?? 'Detalle de lista')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Películas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (lista['peliculas'] == null || lista['peliculas'].isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay películas en esta lista'),
            )
          else
            ...lista['peliculas'].map<Widget>(
              (pelicula) => ListTile(
                title: Text(pelicula['titulo']),
                subtitle: Text(pelicula['genero']),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Series',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (lista['series'] == null || lista['series'].isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay series en esta lista'),
            )
          else
            ...lista['series'].map<Widget>(
              (serie) => ListTile(
                title: Text(serie['nombre']),
                subtitle: Text(serie['genero']),
              ),
            ),
        ],
      ),
    );
  }
}
