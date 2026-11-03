import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'eventos_page.dart';
import 'map_events_page.dart';
import 'feed_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'communities_page.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'mobile_event_search_page.dart';
import 'create_post_page.dart';

/// Navegação compacta para celular, sem landing page dentro da aba Perfil.
/// Eventos é a tela inicial, inclusive para visitantes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color rosa = Color(0xFFEA3F74);
  static const Color texto = Color(0xFF202124);
  static const Color discreto = Color(0xFF6B7280);
  int _aba = 0;
  int? _eventoNotificacao;
  StreamSubscription<String>? _notificacoes;

  @override
  void initState() {
    super.initState();
    NotificationService().inicializar();
    _notificacoes = NotificationService.onNotificationClick.stream.listen((payload) {
      if (!mounted) return;
      setState(() {
        _eventoNotificacao = int.tryParse(payload);
        _aba = 1;
      });
    });
  }

  @override
  void dispose() {
    _notificacoes?.cancel();
    super.dispose();
  }

  Future<void> _entrar({bool cadastrar = false, bool irPerfil = false}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => cadastrar ? const RegisterScreen() : const LoginScreen(),
    ));
    if (!mounted) return;
    setState(() {
      if (irPerfil && AuthService.logado) _aba = 4;
    });
  }

  void _irParaAba(int index) {
    if (index == 4 && !AuthService.logado) {
      _entrar(irPerfil: true);
      return;
    }
    setState(() {
      _aba = index;
      if (index != 1) _eventoNotificacao = null;
    });
  }

  Future<void> _abrirBusca() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (paginaContext) => MobileEventSearchPage(
        onVerNoMapa: (id) {
          Navigator.of(paginaContext).pop();
          if (mounted) {
            setState(() {
              _eventoNotificacao = id;
              _aba = 1;
            });
          }
        },
      ),
    ));
  }

  Future<void> _criarPost() async {
    if (!AuthService.logado) {
      await _entrar();
      if (!AuthService.logado || !mounted) return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostPage()));
    if (mounted) setState(() => _aba = 2);
  }

  Future<void> _abrirMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 14),
                child: Text('Explorar SocialJoin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Comunidades'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunitiesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded),
              title: const Text('Encontrar pessoas'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuarioScreen()));
              },
            ),
            const Divider(),
            if (!AuthService.logado) ...[
              ListTile(
                leading: const Icon(Icons.login_rounded),
                title: const Text('Entrar'),
                onTap: () { Navigator.pop(sheetContext); _entrar(); },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Criar conta'),
                onTap: () { Navigator.pop(sheetContext); _entrar(cadastrar: true); },
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFC93659)),
                title: const Text('Sair da conta', style: TextStyle(color: Color(0xFFC93659))),
                onTap: () {
                  Navigator.pop(sheetContext);
                  AuthService.fazerLogout();
                  setState(() { _aba = 0; _eventoNotificacao = null; });
                },
              ),
          ]),
        ),
      ),
    );
  }

  Widget _conteudo() {
    switch (_aba) {
      case 0:
        return EventosPage(onVerMapa: () => _irParaAba(1));
      case 1:
        return MapEventsPage(
          key: ValueKey('map_$_eventoNotificacao'),
          eventoInicialId: _eventoNotificacao,
        );
      case 2:
        return const FeedPage();
      case 3:
        return const ChatPage();
      case 4:
        return const ProfilePage();
      default:
        return EventosPage(onVerMapa: () => _irParaAba(1));
    }
  }

  Widget _navItem(int index, IconData outline, IconData filled, String label) {
    final ativo = _aba == index;
    return Expanded(
      child: InkWell(
        onTap: () => _irParaAba(index),
        child: Semantics(
          button: true,
          selected: ativo,
          label: label,
          child: SizedBox(
            height: 59,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(ativo ? filled : outline, size: 24, color: ativo ? rosa : texto),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: ativo ? FontWeight.w800 : FontWeight.w500,
                  color: ativo ? rosa : discreto,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        toolbarHeight: 59,
        titleSpacing: 17,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text.rich(
          TextSpan(children: [
            TextSpan(text: 'social', style: TextStyle(color: texto)),
            TextSpan(text: 'join', style: TextStyle(color: rosa)),
          ]),
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -1.1),
        ),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: _abrirBusca,
            icon: const Icon(Icons.search_rounded, color: texto, size: 26),
          ),
          IconButton(
            tooltip: 'Criar publicação',
            onPressed: _criarPost,
            icon: const Icon(Icons.add_box_outlined, color: texto, size: 25),
          ),
          IconButton(
            tooltip: 'Mais opções',
            onPressed: _abrirMenu,
            icon: const Icon(Icons.menu_rounded, color: texto, size: 26),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 670),
        child: _conteudo(),
      )),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            _navItem(0, Icons.event_outlined, Icons.event_rounded, 'Eventos'),
            _navItem(1, Icons.map_outlined, Icons.map_rounded, 'Mapa'),
            _navItem(2, Icons.dynamic_feed_outlined, Icons.dynamic_feed_rounded, 'Feed'),
            _navItem(3, Icons.chat_bubble_outline, Icons.chat_bubble_rounded, 'Chats'),
            _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
          ]),
        ),
      ),
    );
  }
}
