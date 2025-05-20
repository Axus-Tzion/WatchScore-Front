import 'package:flutter/material.dart';
import 'package:watchscorefront/screens/moviesList.dart';
import 'package:watchscorefront/screens/seriesList.dart';
import 'package:watchscorefront/screens/profile_screen.dart';
import 'package:watchscorefront/screens/universal_search_screen.dart';
import 'package:watchscorefront/widgets/registerContent_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Widget> get _tabScreens => [
    _HomeTabContent(userData: widget.userData),
    MoviesList(userData: widget.userData),
    SeriesList(userData: widget.userData),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RegisterContentScreen(userData: widget.userData),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: widget.userData),
        ),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalSearchScreen(userData: widget.userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WatchScore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar películas, series, actores...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.deepPurple[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _navigateToSearch,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _navigateToSearch(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _tabScreens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 2 ? 0 : _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Películas'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Series'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Registrar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  final Map<String, dynamic> userData;

  const _HomeTabContent({required this.userData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Películas populares'),
          SizedBox(
            height: 220,
            child: MoviesList(showOnlyPopular: true, userData: userData),
          ),
          const SectionTitle('Series populares'),
          SizedBox(
            height: 220,
            child: SeriesList(showOnlyPopular: true, userData: userData),
          ),
          const SectionTitle('Recomendaciones para ti'),
          SizedBox(
            height: 220,
            child: MoviesList(showRecommendations: true, userData: userData),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavigationButton(
                  context,
                  'Películas',
                  MoviesList(userData: userData),
                ),
                _buildNavigationButton(
                  context,
                  'Series',
                  SeriesList(userData: userData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String text,
    Widget screen,
  ) {
    return ElevatedButton(
      onPressed:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        'Ver todas las $text',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
