// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:login_front/screens/usuarios_screen.dart';

import 'feed_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int paginaAtual = 0;

  final paginas = [
    const FeedPage(),
    const UsuarioScreen(),
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
            icon: Icon(Icons.article),
            label: 'Posts',
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