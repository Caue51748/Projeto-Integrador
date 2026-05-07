import 'package:flutter/material.dart';

import 'feed_page.dart';
import 'usuarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int paginaAtual = 0;

  final paginas = [
    const FeedPage(),
    const UsuariosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: paginas[paginaAtual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        onTap: (index) {
          setState(() {
            paginaAtual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuários',
          ),
        ],
      ),
    );
  }
}