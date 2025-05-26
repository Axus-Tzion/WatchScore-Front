import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
  List<Map<String, dynamic>> _allContent = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  String? _error;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAllContent(); // Inicia la carga de todo el contenido al inicializar el widget
  }

  @override
  void dispose() {
    _searchController.dispose(); // Libera el controlador de texto
    _debounce
        ?.cancel(); // Cancela cualquier timer de debounce activo para evitar fugas de memoria
    super.dispose();
  }

  Future<void> _loadAllContent() async {
    setState(() {
      _isLoading = true; // Establece el estado de carga a true
      _error = null; // Limpia cualquier mensaje de error previo
    });

    try {
      final moviesResponse = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/peliculas/'),
      );

      final seriesResponse = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/series/'),
      );

      if (moviesResponse.statusCode == 200 &&
          seriesResponse.statusCode == 200) {
        final List<dynamic> rawMovies = jsonDecode(
          utf8.decode(moviesResponse.bodyBytes),
        );
        final List<dynamic> rawSeries = jsonDecode(
          utf8.decode(seriesResponse.bodyBytes),
        );

        final List<Map<String, dynamic>> typedMovies =
            rawMovies
                .map(
                  (m) => Map<String, dynamic>.from(m as Map<dynamic, dynamic>),
                ) // Asegura claves String
                .map((m) => {...m, 'type': 'movie'}) // Añade el campo 'type'
                .toList();

        final List<Map<String, dynamic>> typedSeries =
            rawSeries
                .map(
                  (s) => Map<String, dynamic>.from(s as Map<dynamic, dynamic>),
                ) // Asegura claves String
                .map((s) => {...s, 'type': 'series'}) // Añade el campo 'type'
                .toList();

        if (!mounted) return;

        setState(() {
          _allContent = [...typedMovies, ...typedSeries];
          _isLoading = false; // La carga ha finalizado
        });
      } else {
        if (!mounted) return; // Verificar montado antes de setState
        setState(() {
          _error =
              'Error cargando contenido: Películas: ${moviesResponse.statusCode}, Series: ${seriesResponse.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return; // Verificar montado antes de setState
      setState(() {
        _error = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _hasSearched = true; // Indica que se ha intentado una búsqueda
    });

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final lowerQuery =
        query
            .toLowerCase(); // Convierte el query a minúsculas para una búsqueda insensible a mayúsculas/minúsculas

    setState(() {
      _searchResults =
          _allContent.where((item) {
            if (item['type'] == 'movie') {
              String directorSearchString = '';
              if (item['director'] is List && item['director'].isNotEmpty) {
                directorSearchString =
                    item['director']
                        .map((d) => d['nombre']?.toString() ?? '')
                        .join(' ')
                        .toLowerCase();
              } else if (item['director'] is Map) {
                directorSearchString =
                    item['director']['nombre']?.toString().toLowerCase() ?? '';
              } else if (item['director'] != null) {
                directorSearchString =
                    item['director'].toString().toLowerCase();
              }

              // Realiza la búsqueda en cada campo relevante de la película
              return (item['titulo']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['genero']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  directorSearchString.contains(
                    lowerQuery,
                  ) || // Usa la cadena del director
                  (item['actores']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false);
            }
            // Lógica de búsqueda para series
            else {
              // Extraer el nombre del creador de forma segura para la búsqueda
              String creatorSearchString = '';
              if (item['creador'] is List && item['creador'].isNotEmpty) {
                creatorSearchString =
                    item['creador']
                        .map((c) => c['nombre']?.toString() ?? '')
                        .join(' ')
                        .toLowerCase();
              } else if (item['creador'] is Map) {
                creatorSearchString =
                    item['creador']['nombre']?.toString().toLowerCase() ?? '';
              } else if (item['creador'] != null) {
                creatorSearchString = item['creador'].toString().toLowerCase();
              }

              // Realiza la búsqueda en cada campo relevante de la serie
              return (item['nombre']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (item['genero']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  creatorSearchString.contains(
                    lowerQuery,
                  ) || // Usa la cadena del creador
                  (item['reparto']?.toString().toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false);
            }
          }).toList();
    });
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    final isMovie = item['type'] == 'movie';
    final title = isMovie ? item['titulo'] : item['nombre'];

    String creatorOrDirectorName = 'Desconocido';
    if (isMovie) {
      if (item['director'] is List && item['director'].isNotEmpty) {
        creatorOrDirectorName =
            item['director'][0]['nombre']?.toString() ?? 'Desconocido';
      } else if (item['director'] is Map) {
        creatorOrDirectorName =
            item['director']['nombre']?.toString() ?? 'Desconocido';
      } else if (item['director'] != null) {
        creatorOrDirectorName = item['director'].toString();
      }
    } else {
      if (item['creador'] is List && item['creador'].isNotEmpty) {
        creatorOrDirectorName =
            item['creador'][0]['nombre']?.toString() ?? 'Desconocido';
      }
      // Si 'creador' es un solo objeto
      else if (item['creador'] is Map) {
        creatorOrDirectorName =
            item['creador']['nombre']?.toString() ?? 'Desconocido';
      }
      // Si 'creador' es una cadena
      else if (item['creador'] != null) {
        creatorOrDirectorName = item['creador'].toString();
      }
    }
    // --------------------------------------------------------------------------------------------------

    final subtitle =
        isMovie
            ? 'Película • $creatorOrDirectorName'
            : 'Serie • $creatorOrDirectorName';

    final imageUrl = isMovie ? item['imagen'] : item['imagen'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4, // Eleva la tarjeta para darle un aspecto más tridimensional
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // Bordes redondeados
      child: InkWell(
        onTap: () {
          if (isMovie) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MovieDetailScreen(
                      movie: item, // 'item' ya es Map<String, dynamic>
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
                      serie: item, // 'item' ya es Map<String, dynamic>
                    ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Espaciado interno de la tarjeta
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child:
                    imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                          imageUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 80,
                                height: 120,
                                color: Colors.grey[300],
                                child: Icon(
                                  isMovie
                                      ? Icons.movie_outlined
                                      : Icons.tv_outlined,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                        )
                        : Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[300],
                          child: Icon(
                            isMovie ? Icons.movie_outlined : Icons.tv_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Género: ${item['genero'] ?? 'Desconocido'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
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
          decoration: InputDecoration(
            hintText: 'Buscar películas, series, actores, directores...',
            border: InputBorder.none,
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                        setState(() {
                          _hasSearched = false;
                        });
                      },
                    )
                    : null,
          ),
          onChanged: (query) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              _performSearch(query);
            });
          },
          onSubmitted: (query) {
            _performSearch(query);
          },
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
              : _searchResults.isEmpty && _hasSearched
              ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Ingresa un término de búsqueda para encontrar contenido.'
                      : 'No se encontraron resultados para "${_searchController.text}".',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              )
              : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return _buildResultItem(_searchResults[index]);
                },
              ),
    );
  }
}
