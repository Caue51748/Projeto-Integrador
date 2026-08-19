import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'landing_hero_view.dart';
import 'feed_page.dart';
import 'eventos_page.dart';
import 'map_events_page.dart';
import 'communities_page.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaAtual = 0;

  final titles = const [
    "Início",
    "Feed Geral",
    "Agenda de Eventos",
    "Mapa de Eventos",
    "Comunidades",
    "Usuários",
  ];

  void _selecionarPagina(int index) {
    setState(() => paginaAtual = index);
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
    AuthService.logado = false;
    AuthService.idUsuario = null;
    AuthService.nomeUsuario = null;
    AuthService.emailUsuario = null;
    setState(() {});
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
        return LandingHeroView(
          onExplorar: () => _selecionarPagina(1),
          onEventos: () => _selecionarPagina(2),
          onComunidades: () => _selecionarPagina(4),
          onLogin: _abrirLogin,
          onRegister: _abrirCadastro,
        );
      case 1:
        return const FeedPage();
      case 2:
        return const EventosPage();
      case 3:
        return const MapEventsPage();
      case 4:
        return const CommunitiesPage();
      case 5:
        return const UsuarioScreen();
      default:
        return LandingHeroView(
          onExplorar: () => _selecionarPagina(1),
          onEventos: () => _selecionarPagina(2),
          onComunidades: () => _selecionarPagina(4),
          onLogin: _abrirLogin,
          onRegister: _abrirCadastro,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 920;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Logo SocialJoin à esquerda
                  _buildBrandLogo(),

                  const SizedBox(width: 24),

                  // Links Centrais de Navegação (Desktop)
                  if (isDesktop) ...[
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDesktopNavLink(0, "Início"),
                            _buildDesktopNavLink(1, "Explorar"),
                            _buildDesktopNavLink(2, "Eventos"),
                            _buildDesktopNavLink(3, "Mapa"),
                            _buildDesktopNavLink(4, "Comunidades"),
                            _buildDesktopNavLink(5, "Usuários"),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],

                  // Ações à direita (Entrar / Criar Conta ou Perfil)
                  _buildRightActions(isDesktop),

                  // Botão do Drawer para Mobile/Tablet
                  if (!isDesktop) ...[
                    const SizedBox(width: 8),
                    Builder(
                      builder: (scaffoldContext) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A), size: 26),
                        onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                        tooltip: 'Abrir Menu',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      endDrawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  /// Logotipo SocialJoin inspirado no design Antigravity
  Widget _buildBrandLogo() {
    return InkWell(
      onTap: () => _selecionarPagina(0),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
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
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
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
          ],
        ),
      ),
    );
  }

  /// Links de navegação horizontal no desktop
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

  /// Ações da direita do Header (Entrar / Criar Conta ou Usuário Logado)
  Widget _buildRightActions(bool isDesktop) {
    if (AuthService.logado) {
      final nome = AuthService.nomeUsuario ?? 'Usuário';
      final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : 'U';

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEA3F74),
            radius: 16,
            child: Text(
              inicial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 8),
            Text(
              nome,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(width: 8),
          IconButton(
            onPressed: _fazerLogout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 20),
            tooltip: 'Sair da conta',
          ),
        ],
      );
    }

    // Se visitante não autenticado
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: _abrirLogin,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Entrar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF9ACC6), Color(0xFFEA3F74)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA3F74).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _abrirCadastro,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Criar conta',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Menu Drawer Moderno e Sofisticado
  Widget _buildDrawer() {
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
                  const Column(
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
                        'Viva experiências reais',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
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
                _buildDrawerItem(0, Icons.home_outlined, Icons.home_rounded, "Início (Capa)"),
                _buildDrawerItem(1, Icons.explore_outlined, Icons.explore_rounded, "Explorar Feed"),
                _buildDrawerItem(2, Icons.calendar_month_outlined, Icons.calendar_month_rounded, "Agenda de Eventos"),
                _buildDrawerItem(3, Icons.map_outlined, Icons.map_rounded, "Mapa de Eventos"),
                _buildDrawerItem(4, Icons.groups_outlined, Icons.groups_rounded, "Comunidades"),
                _buildDrawerItem(5, Icons.people_outline, Icons.people_rounded, "Usuários"),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // Rodapé do Drawer com Ações de Autenticação
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
                              const Text('Conectado', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEA3F74), size: 20),
                          onPressed: () {
                            Navigator.pop(context);
                            _fazerLogout();
                          },
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDF0F4) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
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