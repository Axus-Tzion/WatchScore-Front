import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watchscorefront/screens/serieDetails_screen.dart';
import 'package:watchscorefront/screens/seriesRegister_screen.dart';

class SeriesList extends StatefulWidget {
  final bool showOnlyPopular;
  final Map<String, dynamic> userData;

  const SeriesList({
    super.key,
    this.showOnlyPopular = false,
    required this.userData,
  });

  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  List<dynamic> _series = [];
  List<dynamic> _filteredSeries = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSeries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSeries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://watchscore-1.onrender.com/series/'),
        headers: {
          'Authorization': 'Bearer ${widget.userData['token']}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> filteredSeries = data;
        if (widget.showOnlyPopular) {
          filteredSeries = data.take(5).toList();
        }

        setState(() {
          _series = data;
          _filteredSeries = filteredSeries;
          _isLoading = false;
          _searchController.clear();
        });
      } else {
        setState(() {
          _error = 'Error al cargar series: ${response.statusCode}';
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
    final query = _searchController.text.toLowerCase();
    final seriesToDisplay =
        query.isEmpty
            ? _filteredSeries
            : _filteredSeries.where((serie) {
              final titulo = serie['titulo']?.toString().toLowerCase() ?? '';
              final genero = serie['genero']?.toString().toLowerCase() ?? '';
              final creador = serie['creador']?.toString().toLowerCase() ?? '';
              return titulo.contains(query) ||
                  genero.contains(query) ||
                  creador.contains(query);
            }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.showOnlyPopular ? 'Series Populares' : 'Lista de Series',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          if (!widget.showOnlyPopular &&
              widget.userData['identificacion'] != null)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SeriesRegister(userData: widget.userData),
                  ),
                ).then((_) => _fetchSeries());
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (!widget.showOnlyPopular)
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar serie...',
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
                      : seriesToDisplay.isEmpty
                      ? const Center(child: Text('No se encontraron series'))
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: seriesToDisplay.length,
                        itemBuilder: (context, index) {
                          final serie = seriesToDisplay[index];
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SerieDetailScreen(
                                        serie: serie,
                                        userData: widget.userData,
                                      ),
                                ),
                              );
                              if (result == true) {
                                _fetchSeries();
                              }
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
                                        Icons.tv,
                                        size: 40,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      serie['titulo'] ?? 'Sin título',
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
                                      'Género: ${serie['genero'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Temporadas: ${serie['temporadas'] ?? 'Desconocida'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Director: ${serie['director']?['nombre'] ?? 'Desconocido'}',
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
