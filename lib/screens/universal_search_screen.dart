import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:watchscorefront/screens/movieDetails_screen.dart';
import 'package:watchscorefront/screens/serieDetails_screen.dart';

class UniversalSearchScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UniversalSearchScreen({super.key, required this.userData});

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allContent = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllContent();
  }

  Future<void> _loadAllContent() async {
    try {
      // 1. Cargar todas las películas (usando tu endpoint existente)
      final moviesResponse = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/peliculas/'),
      );

      // 2. Cargar todas las series (usando tu endpoint existente)
      final seriesResponse = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/series/'),
      );

      if (moviesResponse.statusCode == 200 &&
          seriesResponse.statusCode == 200) {
        final movies = jsonDecode(utf8.decode(moviesResponse.bodyBytes));
        final series = jsonDecode(utf8.decode(seriesResponse.bodyBytes));

        setState(() {
          _allContent = [
            ...movies.map((m) => {...m, 'type': 'movie'}),
            ...series.map((s) => {...s, 'type': 'series'}),
          ];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error cargando contenido';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      _searchResults =
          _allContent.where((item) {
            // Búsqueda en películas
            if (item['type'] == 'movie') {
              return (item['titulo']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['genero']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['director']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['actores']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false);
            }
            // Búsqueda en series
            else {
              return (item['nombre']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['genero']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['creador']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['reparto']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false);
            }
          }).toList();
    });
  }

  Widget _buildResultItem(dynamic item, BuildContext context) {
    final isMovie = item['type'] == 'movie';
    final title = isMovie ? item['titulo'] : item['nombre'];
    final subtitle =
        isMovie
            ? 'Película • ${item['director'] ?? 'Director desconocido'}'
            : 'Serie • ${item['creador'] ?? 'Creador desconocido'}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          isMovie ? Icons.movie : Icons.tv,
          color: Colors.deepPurple,
        ),
        title: Text(title ?? 'Sin título'),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (isMovie) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MovieDetailScreen(
                      movie: item,
                      userData: widget.userData,
                    ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SerieDetailScreen(
                      userData: widget.userData,
                      serie: item,
                    ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar películas, series, actores, directores...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _searchResults.isEmpty
              ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Ingresa un término de búsqueda'
                      : 'No se encontraron resultados',
                ),
              )
              : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return _buildResultItem(_searchResults[index], context);
                },
              ),
    );
  }
}
