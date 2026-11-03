import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/social_avatar.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/chat_service.dart';
import 'eventos_page.dart';
import 'eventos_home_page.dart';
import 'map_events_page.dart';
import 'feed_page.dart';
import 'social_search_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'communities_page.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'mobile_event_search_page.dart';
import 'create_post_page.dart';

/// Layout principal: Início, Buscar, Eventos, Chats e Perfil.
/// A funcionalidade do mapa permanece acessível no topo e nos eventos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color rosa = Color(0xFFEA3F74);
  static const Color texto = Color(0xFF23252D);
  static const Color discreto = Color(0xFF888D99);

  int _aba = 0;
  int _feedVersao = 0;
  StreamSubscription<String>? _notificacoes;
  Timer? _inboxTimer;
  int _mensagensNaoLidas = 0;
  bool _contadorInicializado = false;
  bool _consultandoMensagens = false;

  @override
  void initState() {
    super.initState();
    NotificationService().inicializar();
    _inboxTimer = Timer.periodic(const Duration(seconds: 14), (_) => _recontarMensagens());
    WidgetsBinding.instance.addPostFrameCallback((_) => _recontarMensagens());
    _notificacoes = NotificationService.onNotificationClick.stream.listen((payload) {
      if (!mounted) return;
      setState(() => _aba = 0);
      final eventoId = int.tryParse(payload);
      if (eventoId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _abrirMapa(eventoId: eventoId);
        });
      }
    });
  }

  @override
  void dispose() {
    _notificacoes?.cancel();
    _inboxTimer?.cancel();
    super.dispose();
  }

  Future<void> _recontarMensagens() async {
    if (_consultandoMensagens || !mounted) return;
    if (!AuthService.logado || AuthService.idUsuario == null) {
      if (_mensagensNaoLidas != 0) setState(() => _mensagensNaoLidas = 0);
      _contadorInicializado = false;
      return;
    }
    _consultandoMensagens = true;
    try {
      final qtd = await ChatService().totalNaoLidas(AuthService.idUsuario!);
      if (!mounted) return;
      if (_contadorInicializado && qtd > _mensagensNaoLidas && _aba != 3) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Você tem ${qtd - _mensagensNaoLidas} nova(s) mensagem(ns).'),
          action: SnackBarAction(label: 'Ver', onPressed: () => _irParaAba(3)),
          duration: const Duration(seconds: 4),
        ));
      }
      _contadorInicializado = true;
      if (qtd != _mensagensNaoLidas) setState(() => _mensagensNaoLidas = qtd);
    } catch (_) {
      // Problemas na consulta de mensagens não interrompem a navegação.
    } finally {
      _consultandoMensagens = false;
    }
  }

  Widget _badgeMensagens(Widget icone) {
    if (_mensagensNaoLidas <= 0) return icone;
    return Stack(clipBehavior: Clip.none, children: [
      icone,
      Positioned(right: -9, top: -6, child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(color: rosa, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5)),
        child: Text(_mensagensNaoLidas > 99 ? '99+' : '$_mensagensNaoLidas',
          textAlign: TextAlign.center, style: const TextStyle(
            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
      )),
    ]);
  }

  Future<void> _entrar({bool cadastrar = false, bool irPerfil = false}) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => cadastrar ? const RegisterScreen() : const LoginScreen(),
    ));
    if (!mounted) return;
    setState(() {
      if (irPerfil && AuthService.logado) {
        _aba = 4;
      }
    });
  }

  void _irParaAba(int index) {
    if (index == 4 && !AuthService.logado) {
      _entrar(irPerfil: true);
      return;
    }
    setState(() => _aba = index);
    _recontarMensagens();
  }

  Future<void> _abrirMapa({int? eventoId}) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MapEventsPage(
        key: ValueKey('mapa_${eventoId ?? 'todos'}'),
        eventoInicialId: eventoId,
      ),
    ));
  }

  Future<void> _abrirBuscaEventos() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (pageContext) => MobileEventSearchPage(
        onVerNoMapa: (id) {
          Navigator.of(pageContext).pop();
          if (mounted) _abrirMapa(eventoId: id);
        },
      ),
    ));
  }

  // Recupera a acao de criar evento, reutilizando a pagina e o formulario antigos.
  Future<void> _abrirCriacaoEvento() async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      await _entrar();
      if (!mounted || !AuthService.logado) return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => EventosPage(onVerMapa: () { _abrirMapa(); }),
    ));
  }

  Future<void> _criarPost() async {
    if (!AuthService.logado) {
      await _entrar();
      if (!mounted || !AuthService.logado) return;
    }
    await Navigator.of(context).push(MaterialPageRoute<dynamic>(
      builder: (_) => const CreatePostPage(),
    ));
    if (mounted) setState(() { _aba = 2; _feedVersao++; });
  }

  Future<void> _abrirMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(23))),
      builder: (sheetContext) => SafeArea(
        child: Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ListTile(title: Text('Explorar', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800))),
            ListTile(leading: const Icon(Icons.add_circle_outline_rounded, color: rosa),
              title: const Text('Criar evento'), onTap: () {
                Navigator.pop(sheetContext); _abrirCriacaoEvento();
              }),
            ListTile(leading: const Icon(Icons.map_outlined),
              title: const Text('Mapa de eventos'), onTap: () {
                Navigator.pop(sheetContext); _abrirMapa();
              }),
            ListTile(leading: const Icon(Icons.travel_explore_outlined),
              title: const Text('Buscar eventos'), onTap: () {
                Navigator.pop(sheetContext); _abrirBuscaEventos();
              }),
            ListTile(leading: const Icon(Icons.groups_outlined),
              title: const Text('Comunidades'), onTap: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const CommunitiesPage()));
              }),
            if (!AuthService.logado) ...[
              const Divider(),
              ListTile(leading: const Icon(Icons.login_rounded),
                title: const Text('Entrar'), onTap: () {
                  Navigator.pop(sheetContext); _entrar();
                }),
              ListTile(leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Criar conta'), onTap: () {
                  Navigator.pop(sheetContext); _entrar(cadastrar: true);
                }),
            ] else ...[
              const Divider(),
              ListTile(leading: const Icon(Icons.logout_rounded, color: Color(0xFFC93659)),
                title: const Text('Sair da conta', style: TextStyle(color: Color(0xFFC93659))),
                onTap: () {
                  Navigator.pop(sheetContext);
                  AuthService.fazerLogout();
                  setState(() { _aba = 0; _feedVersao++; });
                }),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _conteudo() {
    switch (_aba) {
      case 0: return EventosHomePage(
        onCriarEvento: _abrirCriacaoEvento,
        onAbrirMapa: (id) { _abrirMapa(eventoId: id); },
        onVerTodos: () {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => EventosPage(onVerMapa: () { _abrirMapa(); }),
          ));
        },
      );
      case 1: return const SocialSearchPage();
      case 2: return FeedPage(key: ValueKey('feed_$_feedVersao'));
      case 3: return const ChatPage();
      case 4: return const ProfilePage();
      default: return EventosHomePage(onCriarEvento: _abrirCriacaoEvento,
        onAbrirMapa: (id) { _abrirMapa(eventoId: id); }, onVerTodos: () { _irParaAba(0); });
    }
  }

  Widget _navItem(int index, IconData outline, IconData filled, String label) {
    final ativo = _aba == index;
    final icone = index == 4 && AuthService.logado
      ? Container(padding: EdgeInsets.all(ativo ? 2 : 0),
          decoration: BoxDecoration(shape: BoxShape.circle,
            border: ativo ? Border.all(color: rosa, width: 2) : null),
          child: SocialAvatar(nome: AuthService.nomeUsuario ?? 'Você',
            foto: AuthService.fotoPerfil, radius: ativo ? 11 : 13))
      : Icon(ativo ? filled : outline, size: 24, color: ativo ? rosa : texto);
    return Expanded(child: InkWell(
      onTap: () => _irParaAba(index),
      child: Semantics(button: true, selected: ativo, label: label,
        child: SizedBox(height: 69,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedContainer(duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minWidth: 54, minHeight: 33),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ativo ? const Color(0xFFFFE6F0) : Colors.transparent,
                borderRadius: BorderRadius.circular(18)),
              child: Center(child: index == 3 ? _badgeMensagens(icone) : icone)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10,
              fontWeight: ativo ? FontWeight.w800 : FontWeight.w500,
              color: ativo ? rosa : discreto)),
          ]),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        toolbarHeight: 60,
        titleSpacing: 18,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/branding/socialjoin_logo.png',
              width: 35, height: 35, fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (_, error, stack) => Container(
                width: 35, height: 35, alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFFFEAF2),
                  borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.hub_rounded, color: rosa, size: 23),
              ),
            )),
          const SizedBox(width: 9),
          Flexible(child: Text.rich(TextSpan(children: const [
            TextSpan(text: 'social', style: TextStyle(color: texto)),
            TextSpan(text: 'join', style: TextStyle(color: rosa)),
          ]), maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jost(fontSize: 23, fontWeight: FontWeight.w800,
              letterSpacing: -0.65))),
        ]),
        actions: [
          if (_aba == 0 || _aba == 2) IconButton(
            tooltip: 'Buscar pessoas e publicações',
            onPressed: () => _irParaAba(1),
            icon: const Icon(Icons.search_rounded, color: texto, size: 25),
          ),
          if (_aba == 0) IconButton(
            tooltip: 'Criar evento',
            onPressed: _abrirCriacaoEvento,
            icon: const Icon(Icons.add_circle_outline_rounded, color: rosa, size: 27),
          ),
          if (_aba == 2) IconButton(
            tooltip: 'Nova publicação',
            onPressed: _criarPost,
            icon: const Icon(Icons.add_box_outlined, color: texto, size: 26),
          ),
          if (_aba == 0 || _aba == 2) IconButton(
            tooltip: 'Mensagens',
            onPressed: () => _irParaAba(3),
            icon: _badgeMensagens(const Icon(Icons.chat_bubble_outline_rounded,
              color: texto, size: 24)),
          ),
          IconButton(tooltip: 'Menu', onPressed: _abrirMenu,
            icon: const Icon(Icons.more_horiz_rounded, color: texto, size: 26)),
          const SizedBox(width: 5),
        ],
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 710),
        child: _conteudo(),
      )),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEBECF0)))),
        child: SafeArea(top: false,
          child: Row(children: [
            _navItem(0, Icons.explore_outlined, Icons.explore_rounded, 'Eventos'),
            _navItem(1, Icons.search_rounded, Icons.manage_search_rounded, 'Buscar'),
            _navItem(2, Icons.dynamic_feed_outlined, Icons.dynamic_feed_rounded, 'Feed'),
            _navItem(3, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chats'),
            _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
          ]),
        ),
      ),
    );
  }
}
