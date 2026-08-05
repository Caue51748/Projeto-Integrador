import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'feed_page.dart';
import 'eventos_page.dart';
import 'map_events_page.dart';
import 'communities_page.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaAtual = 0;

  final paginas = const [
    FeedPage(),
    EventosPage(),
    MapEventsPage(),
    CommunitiesPage(),
    UsuarioScreen(),
  ];

  final titles = const [
    "Feed Geral",
    "Agenda de Eventos",
    "Mapa de Eventos",
    "Comunidades",
    "Usuários",
  ];

  void _selecionarPagina(int index) {
    setState(() => paginaAtual = index);
    Navigator.pop(context); // Fecha o drawer
  }

  void _fazerLogout() {
    AuthService.logado = false;
    AuthService.idUsuario = null;
    AuthService.nomeUsuario = null;
    setState(() {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[paginaAtual]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nenhuma nova notificação no momento.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1C23), // Azul/cinza escuro do design original
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEA3F74), Color(0xFFFF5B8C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.forum, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resenha/Morte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Plataforma de Eventos',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 12),

            // Itens do Menu Lateral
            _buildMenuItem(0, Icons.feed_outlined, Icons.feed, "Feed Geral"),
            _buildMenuItem(1, Icons.calendar_month_outlined, Icons.calendar_month, "Agenda de Eventos"),
            _buildMenuItem(2, Icons.map_outlined, Icons.map, "Mapa de Eventos"),
            _buildMenuItem(3, Icons.groups_outlined, Icons.groups, "Comunidades"),
            _buildMenuItem(4, Icons.people_outline, Icons.people, "Usuários"),

            const Spacer(),

            // Logged user card & Logout
            if (AuthService.logado) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFEA3F74),
                      radius: 18,
                      child: Text(
                        (AuthService.nomeUsuario ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AuthService.nomeUsuario ?? 'Usuário',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                              SizedBox(width: 4),
                              Text('Conectado', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA3F74),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _fazerLogout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text("Sair da Conta", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA3F74),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text("Fazer Login", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
      body: paginas[paginaAtual],
    );
  }

  Widget _buildMenuItem(int index, IconData icon, IconData activeIcon, String title) {
    bool isSelected = paginaAtual == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEA3F74) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        onTap: () => _selecionarPagina(index),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: Colors.white,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}