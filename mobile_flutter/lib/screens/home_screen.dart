import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'eventos_page.dart';
import 'map_events_page.dart';
import 'feed_page.dart';
import 'communities_page.dart';
import 'profile_page.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'mobile_welcome_view.dart';
import 'mobile_event_search_page.dart';

/// Navegação móvel centrada em Eventos. A tela Web/desktop é um projeto separado.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pagina = 0;
  int? _eventoNotificacao;
  StreamSubscription<String>? _notificationSub;

  @override
  void initState() {
    super.initState();
    NotificationService().inicializar();
    _notificationSub = NotificationService.onNotificationClick.stream.listen((id) {
      if (!mounted) return;
      setState(() { _eventoNotificacao = int.tryParse(id); _pagina = 1; });
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (mounted) setState(() {});
  }

  Future<void> _cadastro() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
    if (mounted) setState(() {});
  }

  void _abrirPesquisa() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (contextPesquisa) => MobileEventSearchPage(
        onVerNoMapa: (id) {
          Navigator.of(contextPesquisa).pop();
          if (mounted) setState(() { _eventoNotificacao = id; _pagina = 1; });
        },
      ),
    ));
  }

  Widget _conteudo() {
    switch (_pagina) {
      case 0: return EventosPage(onVerMapa: () => setState(() => _pagina = 1));
      case 1: return MapEventsPage(
        eventoInicialId: _eventoNotificacao,
        key: ValueKey('map_${_eventoNotificacao ?? 'padrao'}'),
      );
      case 2: return const FeedPage();
      case 3: return const CommunitiesPage();
      case 4:
        return AuthService.logado
          ? const ProfilePage()
          : MobileWelcomeView(
              onLogin: _login,
              onRegister: _cadastro,
              onExplorar: () => setState(() => _pagina = 0),
            );
      default: return const EventosPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text.rich(TextSpan(children: [
          TextSpan(text: 'Social', style: TextStyle(color: Color(0xFF111827))),
          TextSpan(text: 'Join', style: TextStyle(color: Color(0xFFEA3F74))),
        ]), style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
        actions: [
          IconButton(
            tooltip: 'Buscar eventos',
            onPressed: _abrirPesquisa,
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Pessoas',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UsuarioScreen()),
            ),
            icon: const Icon(Icons.people_outline_rounded),
          ),
          if (AuthService.logado)
            PopupMenuButton<String>(
              tooltip: 'Minha conta',
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (v) {
                if (v == 'perfil') setState(() => _pagina = 4);
                if (v == 'sair') {
                  AuthService.fazerLogout();
                  setState(() { _pagina = 0; _eventoNotificacao = null; });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Você saiu da conta.')),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'perfil', child: Text('Meu perfil')),
                PopupMenuItem(value: 'sair', child: Text('Sair')),
              ],
            )
          else
            TextButton(onPressed: _login, child: const Text('Entrar')),
          const SizedBox(width: 4),
        ],
      ),
      body: _conteudo(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        height: 74,
        selectedIndex: _pagina,
        indicatorColor: const Color(0xFFFFE3EC),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() {
          _pagina = i;
          if (i != 1) _eventoNotificacao = null;
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.dynamic_feed_outlined), selectedIcon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Grupos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
