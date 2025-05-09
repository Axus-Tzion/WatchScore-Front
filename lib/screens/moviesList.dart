import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watchscorefront/screens/movieDetails_screen.dart';
import 'package:watchscorefront/screens/moviesRegister_screen.dart';

class MoviesList extends StatefulWidget {
  final bool showOnlyPopular;
  final bool showRecommendations;

  const MoviesList({
    super.key,
    this.showOnlyPopular = false,
    this.showRecommendations = false,
  });

  @override
  State<MoviesList> createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  List<dynamic> _movies = [];
  List<dynamic> _filteredMovies = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8860/peliculas/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Aplicar filtros según los parámetros
        List<dynamic> filteredMovies = data;

        if (widget.showOnlyPopular) {
          // Filtra las primeras 5 como "populares" (ejemplo)
          filteredMovies = data.take(5).toList();
        }

        if (widget.showRecommendations) {
          // Filtra algunas como recomendadas (ejemplo)
          filteredMovies = data.where((movie) => movie['id'] % 3 == 0).toList();
        }

        setState(() {
          _movies = data;
          _filteredMovies = filteredMovies;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar películas: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    final moviesToDisplay =
        _searchController.text.isEmpty
            ? _filteredMovies
            : _filteredMovies
                .where(
                  (movie) =>
                      movie['titulo'].toString().toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ) ||
                      movie['genero'].toString().toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ) ||
                      movie['director'].toString().toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ),
                )
                .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.showOnlyPopular
              ? 'Películas Populares'
              : widget.showRecommendations
              ? 'Recomendaciones'
              : 'Lista de Películas',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (!widget.showOnlyPopular && !widget.showRecommendations)
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar película...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text(_error!))
                      : moviesToDisplay.isEmpty
                      ? const Center(child: Text('No se encontraron películas'))
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: moviesToDisplay.length,
                        itemBuilder: (context, index) {
                          final movie = moviesToDisplay[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MovieDetailScreen(movie: movie),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              shadowColor: Colors.deepPurple[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.deepPurple[50],
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.movie,
                                        size: 40,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      movie['titulo'] ?? 'Sin título',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Género: ${movie['genero'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Duración: ${movie['duracion'] ?? 'Desconocida'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Director: ${movie['director'] ?? 'Desconocido'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
