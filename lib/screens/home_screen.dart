import 'package:flutter/material.dart';
import 'package:watchscorefront/screens/seriesList.dart';
import 'package:watchscorefront/screens/profile_screen.dart';
import 'package:watchscorefront/widgets/registerContent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Map<String, dynamic>
  _userData; // Cambiado a Map para guardar todos los datos del usuario

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ahora recibimos todos los datos del usuario, no solo el email
    _userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
  }

  final List<Widget> _tabScreens = [
    const _HomeTabContent(),
    const Placeholder(child: Center(child: Text('Pantalla de Películas'))),
    const SeriesList(),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterContentScreen()),
      );
    } else if (index == 4) {
      Navigator.pushNamed(
        context,
        '/profile',
        arguments: _userData, // Pasamos todos los datos del usuario al perfil
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WatchScore', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: _userData, // También accesible desde el ícono
              );
            },
          ),
        ],
      ),
      body: _tabScreens[_currentIndex],
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
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionTitle('Películas populares'),
        const SectionTitle('Series populares'),
        SizedBox(height: 300, child: SeriesList()),
        ElevatedButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SeriesList()),
              ),
          child: const Text('Ver todas las series'),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
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
