import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'feed_page.dart';
import 'eventos_page.dart';
import 'map_events_page.dart';
import 'communities_page.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_page.dart';
import 'mobile_welcome_view.dart';
import 'mobile_event_search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaAtual = 0;
  int? _eventoNotificacaoId;
  StreamSubscription<String>? _notificationSub;

  final titles = const [
    "Início",
    "Pesquisar",
    "Eventos",
    "Comunidades",
    "Perfil",
    "Mapa",
    "Usuários",
  ];

  @override
  void initState() {
    super.initState();
    NotificationService().inicializar();
    _notificationSub = NotificationService.onNotificationClick.stream.listen((payload) {
      final id = int.tryParse(payload);
      if (id != null && mounted) {
        setState(() {
          _eventoNotificacaoId = id;
          paginaAtual = 5; // Redireciona diretamente para o Mapa de Eventos
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  void _selecionarPagina(int index) {
    setState(() {
      paginaAtual = index;
      if (index != 5) {
        _eventoNotificacaoId = null;
      }
    });
  }

  void _abrirLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ).then((_) => setState(() {}));
  }

  void _abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    ).then((_) => setState(() {}));
  }

  void _fazerLogout() {
    AuthService.fazerLogout();
    setState(() {
      paginaAtual = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você saiu da sua conta.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBody() {
    switch (paginaAtual) {
      case 0:
        return const FeedPage();
      case 1:
        return MobileEventSearchPage(
          onVerNoMapa: (id) {
            setState(() {
              _eventoNotificacaoId = id;
              paginaAtual = 5;
            });
          },
        );
      case 2:
        return const EventosPage();
      case 3:
        return const CommunitiesPage();
      case 4:
        if (AuthService.logado) {
          return const ProfilePage();
        }
        return MobileWelcomeView(
          onLogin: _abrirLogin,
          onRegister: _abrirCadastro,
          onExplorar: () => _selecionarPagina(0),
        );
      case 5:
        return MapEventsPage(
          eventoInicialId: _eventoNotificacaoId,
          key: ValueKey(_eventoNotificacaoId),
        );
      case 6:
        return const UsuarioScreen();
      default:
        return const FeedPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 920;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  // Logotipo SocialJoin
                  Flexible(
                    child: _buildBrandLogo(),
                  ),

                  if (isDesktop) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDesktopNavLink(0, "Início"),
                              _buildDesktopNavLink(1, "Pesquisar"),
                              _buildDesktopNavLink(2, "Eventos"),
                              _buildDesktopNavLink(5, "Mapa"),
                              _buildDesktopNavLink(3, "Comunidades"),
                              _buildDesktopNavLink(6, "Usuários"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],

                  // Ações Rápidas do Topo (Busca rápida, Mapa e Perfil/Menu)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          paginaAtual == 1 ? Icons.search_rounded : Icons.search_outlined,
                          color: paginaAtual == 1 ? const Color(0xFFEA3F74) : const Color(0xFF0F172A),
                          size: 22,
                        ),
                        onPressed: () => _selecionarPagina(1),
                        tooltip: 'Pesquisar Eventos',
                      ),
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          paginaAtual == 5 ? Icons.map_rounded : Icons.map_outlined,
                          color: paginaAtual == 5 ? const Color(0xFFEA3F74) : const Color(0xFF0F172A),
                          size: 22,
                        ),
                        onPressed: () => _selecionarPagina(5),
                        tooltip: 'Mapa de Eventos',
                      ),
                      const SizedBox(width: 2),

                      if (AuthService.logado)
                        GestureDetector(
                          onTap: () => _selecionarPagina(4),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFFEA3F74),
                            radius: 14,
                            child: Text(
                              (AuthService.nomeUsuario ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: _abrirLogin,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF0F4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Color(0xFFEA3F74),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(width: 2),

                      Builder(
                        builder: (scaffoldContext) => IconButton(
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A), size: 24),
                          onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                          tooltip: 'Menu',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      endDrawer: _buildDrawer(isDesktop),
      body: _buildBody(),

      // Barra de Navegação Inferior (Bottom Navigation Bar) inspirada em Instagram/Twitter/Reddit
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: SafeArea(
                child: BottomNavigationBar(
                  currentIndex: _mapPaginaParaBottomNav(paginaAtual),
                  onTap: (navIndex) {
                    final pageIndex = _mapBottomNavParaPagina(navIndex);
                    _selecionarPagina(pageIndex);
                  },
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFFEA3F74),
                  unselectedItemColor: const Color(0xFF94A3B8),
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.dynamic_feed_outlined),
                      activeIcon: Icon(Icons.dynamic_feed_rounded),
                      label: 'Feed',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.search_rounded),
                      activeIcon: Icon(Icons.search_rounded),
                      label: 'Pesquisar',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month_outlined),
                      activeIcon: Icon(Icons.calendar_month_rounded),
                      label: 'Eventos',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.groups_outlined),
                      activeIcon: Icon(Icons.groups_rounded),
                      label: 'Grupos',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline_rounded),
                      activeIcon: const Icon(Icons.person_rounded),
                      label: AuthService.logado ? 'Perfil' : 'Conta',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  int _mapPaginaParaBottomNav(int page) {
    switch (page) {
      case 0:
        return 0; // Feed
      case 1:
        return 1; // Pesquisar
      case 2:
        return 2; // Eventos
      case 3:
        return 3; // Grupos/Comunidades
      case 4:
        return 4; // Perfil / Conta
      default:
        return 0;
    }
  }

  int _mapBottomNavParaPagina(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0; // Feed
      case 1:
        return 1; // Pesquisar
      case 2:
        return 2; // Eventos
      case 3:
        return 3; // Comunidades
      case 4:
        return 4; // Perfil / Welcome
      default:
        return 0;
    }
  }

  Widget _buildBrandLogo() {
    return InkWell(
      onTap: () => _selecionarPagina(0),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF9ACC6), Color(0xFFEA3F74)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA3F74).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: Color(0xFF0F172A),
                    ),
                    children: [
                      TextSpan(text: 'Social'),
                      TextSpan(
                        text: 'Join',
                        style: TextStyle(
                          color: Color(0xFFEA3F74),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopNavLink(int index, String label) {
    final bool isSelected = paginaAtual == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => _selecionarPagina(index),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFFDF0F4) : Colors.transparent,
          foregroundColor: isSelected ? const Color(0xFFEA3F74) : const Color(0xFF475569),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(bool isDesktop) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9ACC6), Color(0xFFEA3F74)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SocialJoin',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Sua rede social de eventos',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(0, Icons.dynamic_feed_outlined, Icons.dynamic_feed_rounded, "Início"),
                _buildDrawerItem(1, Icons.search_rounded, Icons.search_rounded, "Pesquisar"),
                _buildDrawerItem(2, Icons.calendar_month_outlined, Icons.calendar_month_rounded, "Eventos"),
                _buildDrawerItem(5, Icons.map_outlined, Icons.map_rounded, "Mapa"),
                _buildDrawerItem(3, Icons.groups_outlined, Icons.groups_rounded, "Comunidades"),
                if (isDesktop)
                  _buildDrawerItem(6, Icons.people_outline_rounded, Icons.people_rounded, "Usuários"),
                if (AuthService.logado)
                  _buildDrawerItem(4, Icons.person_outline_rounded, Icons.person_rounded, "Meu Perfil"),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: AuthService.logado
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF9ACC6).withValues(alpha: 0.5)),
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
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                AuthService.username != null ? '@${AuthService.username}' : 'Conectado',
                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEA3F74), size: 20),
                          onPressed: () {
                            Navigator.pop(context);
                            _fazerLogout();
                          },
                          tooltip: 'Sair',
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA3F74),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _abrirLogin();
                          },
                          child: const Text("Fazer Login", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _abrirCadastro();
                          },
                          child: const Text("Criar Conta", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, IconData activeIcon, String title) {
    final bool isSelected = paginaAtual == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: isSelected ? const Color(0xFFFDF0F4) : Colors.transparent,
        dense: true,
        onTap: () {
          _selecionarPagina(index);
          Navigator.pop(context);
        },
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFF64748B),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFF334155),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
