import 'dart:async';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool carregando = true;
  String? erro;
  List<Usuario> usuarios = [];
  String busca = '';
  @override
  void initState() { super.initState(); _carregar(); }

  Future<void> _carregar() async {
    if (!AuthService.logado || AuthService.idUsuario == null) return;
    setState(() { carregando = true; erro = null; });
    try {
      final lista = await UsuarioService().listarUsuarios();
      if (mounted) {
        setState(() {
          usuarios = lista.where((u) =>
              u.idUsuario != null && u.idUsuario != AuthService.idUsuario).toList();
          carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { carregando = false; erro = 'Não foi possível carregar os usuários: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFFEA3F74)),
          SizedBox(height: 16),
          Text('Entre na sua conta para conversar', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      )));
    }
    final filtrados = usuarios.where((u) => u.nome.toLowerCase().contains(busca.toLowerCase()) ||
        (u.username ?? '').toLowerCase().contains(busca.toLowerCase())).toList();
    return Scaffold(backgroundColor: const Color(0xFFF7F8FA),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20,22,20,12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mensagens', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
            const SizedBox(height: 5),
            const Text('Converse com pessoas da comunidade', style: TextStyle(color: Color(0xFF6A7184))),
            const SizedBox(height: 20),
            TextField(onChanged: (s) => setState(() => busca = s),
              decoration: const InputDecoration(hintText: 'Encontrar uma pessoa...',
                prefixIcon: Icon(Icons.search_rounded))),
          ],
        )),
        Expanded(child: carregando ? const Center(child: CircularProgressIndicator()) :
          erro != null ? Center(child: Text(erro!, textAlign: TextAlign.center)) :
          RefreshIndicator(onRefresh: _carregar, child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtrados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final u = filtrados[index];
              return Card(child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(radius: 25, backgroundColor: const Color(0xFFE9E6FF),
                  child: Text(u.nome.isEmpty ? '?' : u.nome[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFFEA3F74), fontWeight: FontWeight.w800))),
                title: Text(u.nome, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(u.username == null ? 'Iniciar conversa' : '@${u.username}'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ConversaPage(usuario: u))),
              ));
            },
          )),
        ),
      ]),
    );
  }
}

class ConversaPage extends StatefulWidget {
  final Usuario usuario;
  const ConversaPage({super.key, required this.usuario});
  @override
  State<ConversaPage> createState() => _ConversaPageState();
}

class _ConversaPageState extends State<ConversaPage> {
  final ChatService _service = ChatService();
  final TextEditingController _mensagem = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<MensagemChat> _mensagens = [];
  Timer? _timer;
  String? _erro;
  bool _loading = true;
  bool _enviando = false;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _carregar(silencioso: true));
  }
  @override
  void dispose() { _timer?.cancel(); _mensagem.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _carregar({bool silencioso = false}) async {
    if (_carregando || AuthService.idUsuario == null || widget.usuario.idUsuario == null) return;
    _carregando = true;
    try {
      final lista = await _service.listar(AuthService.idUsuario!, widget.usuario.idUsuario!);
      if (!mounted) return;
      final mudou = lista.length != _mensagens.length;
      setState(() { _mensagens = lista; _erro = null; _loading = false; });
      if (mudou) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scroll.hasClients) return;
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; if (!silencioso || _mensagens.isEmpty) _erro = '$e'; });
    } finally { _carregando = false; }
  }

  Future<void> _enviar() async {
    final texto = _mensagem.text.trim();
    if (texto.isEmpty || _enviando || AuthService.idUsuario == null || widget.usuario.idUsuario == null) return;
    setState(() { _enviando = true; _erro = null; });
    try {
      await _service.enviar(eu: AuthService.idUsuario!, outro: widget.usuario.idUsuario!, texto: texto);
      _mensagem.clear();
      await _carregar();
    } catch (e) { if (mounted) setState(() => _erro = '$e'); }
    finally { if (mounted) setState(() => _enviando = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(title: Row(children: [
      CircleAvatar(backgroundColor: const Color(0xFFE9E6FF),
        child: Text(widget.usuario.nome.isEmpty ? '?' : widget.usuario.nome[0].toUpperCase(),
          style: const TextStyle(color: Color(0xFFEA3F74), fontWeight: FontWeight.w800))),
      const SizedBox(width: 10),
      Expanded(child: Text(widget.usuario.nome, overflow: TextOverflow.ellipsis)),
    ])),
    body: SafeArea(child: Column(children: [
      if (_erro != null) Material(color: const Color(0xFFFFE8EE), child: Padding(
        padding: const EdgeInsets.all(12), child: Text(_erro!,
          style: const TextStyle(color: Color(0xFFAD2042), fontSize: 12)))),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) :
        _mensagens.isEmpty ? const Center(child: Text('Nenhuma mensagem ainda.\nComece a conversa! ',
          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7C8293)))) :
        ListView.builder(controller: _scroll,
          padding: const EdgeInsets.fromLTRB(14,16,14,20),
          itemCount: _mensagens.length, itemBuilder: (context, index) {
            final m = _mensagens[index];
            final minha = m.remetenteId == AuthService.idUsuario;
            return Align(alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .76),
                decoration: BoxDecoration(color: minha ? const Color(0xFFEA3F74) : Colors.white,
                  borderRadius: BorderRadius.only(topLeft: const Radius.circular(17),
                    topRight: const Radius.circular(17),
                    bottomLeft: Radius.circular(minha ? 17 : 4),
                    bottomRight: Radius.circular(minha ? 4 : 17))),
                child: Text(m.texto, style: TextStyle(color: minha ? Colors.white : const Color(0xFF161A29),
                  height: 1.4))),
            );
          })),
      Container(padding: const EdgeInsets.fromLTRB(12,10,12,10), color: Colors.white,
        child: Row(children: [
          Expanded(child: TextField(controller: _mensagem,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1, maxLines: 4,
            decoration: const InputDecoration(hintText: 'Escreva uma mensagem...',
              border: InputBorder.none))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: _enviando ? null : _enviar,
            icon: _enviando ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.arrow_upward_rounded)),
        ])),
    ])),
  );
}
