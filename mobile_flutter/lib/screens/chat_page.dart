import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../services/chat_service.dart';
import '../services/social_attachments_service.dart';
import '../widgets/social_avatar.dart';
import 'public_profile_page.dart';

const _rosa = Color(0xFFEA3F74);
const _fundo = Color(0xFFF7F8FA);

/// Caixa de entrada real: carrega /conversas/usuario/{id}, não /usuarios.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chat = ChatService();
  List<ConversaComMensagens> _conversas = [];
  Map<int, int> _naoLidas = {};
  bool _carregando = true;
  String? _erro;
  String _busca = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => _carregar(silencioso: true));
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _carregar({bool silencioso = false}) async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      if (mounted) setState(() => _carregando = false);
      return;
    }
    if (!silencioso && mounted) setState(() { _carregando = true; _erro = null; });
    try {
      final id = AuthService.idUsuario!;
      final dados = await _chat.caixaDeEntrada(id);
      final counts = await Future.wait(dados.map((d) =>
        _chat.naoLidas(id, d.conversa.idConversa, d.mensagens)));
      if (!mounted) return;
      final valores = <int, int>{};
      for (var i = 0; i < dados.length; i++) {
        valores[dados[i].conversa.idConversa] = counts[i];
      }
      setState(() { _conversas = dados; _naoLidas = valores; _carregando = false; _erro = null; });
    } catch (e) {
      if (mounted) setState(() { _erro = '$e'; _carregando = false; });
    }
  }

  Future<void> _novaConversa() async {
    if (AuthService.idUsuario == null) return;
    try {
      final pessoas = (await UsuarioService().listarUsuarios())
          .where((u) => u.idUsuario != null && u.idUsuario != AuthService.idUsuario).toList();
      if (!mounted) return;
      final busca = TextEditingController();
      await showModalBottomSheet<void>(context: context, isScrollControlled: true,
        showDragHandle: true, builder: (modalCtx) => StatefulBuilder(
          builder: (ctx, atualizar) {
            final filtro = busca.text.toLowerCase().trim();
            final visiveis = pessoas.where((u) => u.nome.toLowerCase().contains(filtro) ||
                (u.username ?? '').toLowerCase().contains(filtro)).toList();
            return SafeArea(child: Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, MediaQuery.of(ctx).viewInsets.bottom + 14),
              child: SizedBox(height: MediaQuery.of(ctx).size.height * .65, child: Column(children: [
                const Align(alignment: Alignment.centerLeft, child: Text('Nova mensagem',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
                const SizedBox(height: 12),
                TextField(controller: busca, onChanged: (_) => atualizar(() {}),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar pessoa...')),
                const SizedBox(height: 10),
                Expanded(child: ListView.builder(itemCount: visiveis.length, itemBuilder: (_, i) {
                  final p = visiveis[i];
                  return ListTile(leading: SocialAvatar(nome: p.nome, foto: p.fotoPerfil),
                    title: Text(p.nome), subtitle: Text('@${p.username ?? ''}'), onTap: () async {
                      Navigator.pop(modalCtx);
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => ConversaPage(usuario: p)));
                      if (mounted) _carregar();
                    });
                })),
              ])),
            ));
          }));
      busca.dispose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir a busca: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      return const Center(child: Text('Faça login para ver suas mensagens.'));
    }
    final filtrados = _conversas.where((c) => c.conversa.nome.toLowerCase().contains(_busca.toLowerCase()) ||
        (c.conversa.username ?? '').toLowerCase().contains(_busca.toLowerCase())).toList();
    return Scaffold(backgroundColor: _fundo,
      floatingActionButton: FloatingActionButton.extended(onPressed: _novaConversa,
        backgroundColor: _rosa, foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_square), label: const Text('Nova mensagem')),
      body: RefreshIndicator(onRefresh: _carregar, child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 23, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mensagens', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Suas conversas recentes', style: TextStyle(color: Color(0xFF788092))),
            const SizedBox(height: 16),
            TextField(onChanged: (s) => setState(() => _busca = s),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar conversas')),
          ]))),
        if (_carregando) const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
        if (!_carregando && _erro != null) SliverFillRemaining(child: Center(child: Text('Erro ao buscar conversas.\n$_erro', textAlign: TextAlign.center))),
        if (!_carregando && _erro == null && filtrados.isEmpty)
          const SliverFillRemaining(child: Center(child: Padding(padding: EdgeInsets.all(30),
              child: Text('Ainda não há mensagens. Use “Nova mensagem” para começar uma conversa.',
                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF858A98)))))),
        if (!_carregando && _erro == null && filtrados.isNotEmpty)
          SliverList(delegate: SliverChildBuilderDelegate((context, index) {
            final d = filtrados[index];
            final c = d.conversa;
            final unread = _naoLidas[c.idConversa] ?? 0;
            final pre = d.ultima?.texto ?? '';
            final texto = SocialAttachmentsService.ehImagem(pre) ? 'Enviou uma imagem' : pre;
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
              child: Card(elevation: 0, color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PublicProfilePage(usuarioId: c.idOutroUsuario))),
                    child: SocialAvatar(nome: c.nome, foto: c.fotoPerfil, radius: 26)),
                  title: Text(c.nome, style: TextStyle(fontWeight: unread > 0 ? FontWeight.w900 : FontWeight.w700)),
                  subtitle: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: unread > 0 ? const Color(0xFF283146) : const Color(0xFF81889A))),
                  trailing: unread > 0 ? CircleAvatar(radius: 13, backgroundColor: _rosa,
                    child: Text(unread > 99 ? '99+' : '$unread', style: const TextStyle(color: Colors.white, fontSize: 10)))
                    : const Icon(Icons.chevron_right, color: Color(0xFFB5B9C6)),
                  onTap: () async {
                    final usuario = Usuario(idUsuario: c.idOutroUsuario, nome: c.nome,
                      email: '', senha: '', username: c.username, fotoPerfil: c.fotoPerfil);
                    await Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      ConversaPage(usuario: usuario, idConversa: c.idConversa)));
                    if (mounted) _carregar();
                  },
                )));
          }, childCount: filtrados.length)),
      ])),
    );
  }
}

class ConversaPage extends StatefulWidget {
  final Usuario usuario;
  final int? idConversa;
  const ConversaPage({super.key, required this.usuario, this.idConversa});
  @override
  State<ConversaPage> createState() => _ConversaPageState();
}

class _ConversaPageState extends State<ConversaPage> {
  final ChatService _chat = ChatService();
  final TextEditingController _texto = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<MensagemChat> _mensagens = [];
  Timer? _timer;
  int? _idConversa;
  bool _carregando = true;
  bool _enviando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _idConversa = widget.idConversa;
    _atualizar();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _atualizar(silencioso: true));
  }
  @override
  void dispose() { _timer?.cancel(); _texto.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _atualizar({bool silencioso = false}) async {
    final eu = AuthService.idUsuario;
    final outro = widget.usuario.idUsuario;
    if (eu == null || outro == null) return;
    try {
      _idConversa ??= (await _chat.buscarOuCriar(eu, outro)).idConversa;
      final lista = await _chat.listarPorConversa(_idConversa!);
      if (!mounted) return;
      final mudou = lista.length != _mensagens.length;
      setState(() { _mensagens = lista; _carregando = false; _erro = null; });
      await _chat.marcarLida(eu, _idConversa!, lista);
      if (mudou) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
      }
    } catch (e) {
      if (mounted && (!silencioso || _mensagens.isEmpty)) setState(() { _erro = '$e'; _carregando = false; });
    }
  }

  Future<void> _enviar([String? imagem]) async {
    final valor = imagem ?? _texto.text.trim();
    if (valor.isEmpty || _enviando || AuthService.idUsuario == null) return;
    setState(() { _enviando = true; _erro = null; });
    try {
      _idConversa ??= (await _chat.buscarOuCriar(AuthService.idUsuario!, widget.usuario.idUsuario!)).idConversa;
      await _chat.enviarPorConversa(idConversa: _idConversa!, eu: AuthService.idUsuario!, texto: valor);
      if (imagem == null) _texto.clear();
      await _atualizar();
    } catch (e) { if (mounted) setState(() => _erro = '$e'); }
    finally { if (mounted) setState(() => _enviando = false); }
  }

  Future<void> _enviarFoto() async {
    if (_enviando || AuthService.idUsuario == null) return;
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (p == null) return;
    setState(() => _enviando = true);
    try {
      _idConversa ??= (await _chat.buscarOuCriar(AuthService.idUsuario!, widget.usuario.idUsuario!)).idConversa;
      final url = await SocialAttachmentsService().upload(tipo: 'chat', id: _idConversa!,
        usuarioId: AuthService.idUsuario!, bytes: await p.readAsBytes(), nome: p.name);
      await _chat.enviarPorConversa(idConversa: _idConversa!, eu: AuthService.idUsuario!,
        texto: '${SocialAttachmentsService.imagePrefix}$url');
      await _atualizar();
    } catch (e) { if (mounted) setState(() => _erro = 'Não foi possível enviar a foto: $e'); }
    finally { if (mounted) setState(() => _enviando = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: _fundo,
    appBar: AppBar(backgroundColor: Colors.white, titleSpacing: 4,
      title: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => PublicProfilePage(usuarioId: widget.usuario.idUsuario!))),
        child: Row(children: [
          SocialAvatar(nome: widget.usuario.nome, foto: widget.usuario.fotoPerfil, radius: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.usuario.nome, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const Text('Ver perfil', style: TextStyle(color: Color(0xFF82899A), fontSize: 11)),
          ])),
        ])),
      actions: [IconButton(tooltip: 'Ver perfil', icon: const Icon(Icons.person_outline),
        onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PublicProfilePage(usuarioId: widget.usuario.idUsuario!))))],
    ),
    body: SafeArea(child: Column(children: [
      if (_erro != null) Container(width: double.infinity, color: const Color(0xFFFFE5ED),
          padding: const EdgeInsets.all(10), child: Text(_erro!, style: const TextStyle(color: Color(0xFFA51C46)))),
      Expanded(child: _carregando ? const Center(child: CircularProgressIndicator()) :
        _mensagens.isEmpty ? const Center(child: Text('Nenhuma mensagem ainda.\nComece a conversa!',
            textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF858C9D)))) :
        ListView.builder(controller: _scroll, padding: const EdgeInsets.all(16),
          itemCount: _mensagens.length, itemBuilder: (context, i) {
            final m = _mensagens[i];
            final minha = m.remetenteId == AuthService.idUsuario;
            final imagem = SocialAttachmentsService.imagemDaMensagem(m.texto);
            return Align(alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(margin: const EdgeInsets.only(bottom: 10),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
                decoration: BoxDecoration(color: minha ? _rosa : Colors.white,
                    borderRadius: BorderRadius.circular(17)),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (imagem != null) ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.network(imagem, height: 200, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('Imagem indisponível')))
                  else Text(m.texto, style: TextStyle(color: minha ? Colors.white : const Color(0xFF252938), height: 1.4)),
                  if (m.enviadaEm != null) Padding(padding: const EdgeInsets.only(top: 5),
                    child: Text('${m.enviadaEm!.hour.toString().padLeft(2,'0')}:${m.enviadaEm!.minute.toString().padLeft(2,'0')}',
                      style: TextStyle(color: minha ? Colors.white70 : Colors.black38, fontSize: 10))),
                ])),
            );
          })),
      Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
        child: Row(children: [
          IconButton(tooltip: 'Enviar imagem', onPressed: _enviando ? null : _enviarFoto,
            icon: const Icon(Icons.add_photo_alternate_outlined, color: _rosa)),
          Expanded(child: TextField(controller: _texto, minLines: 1, maxLines: 4,
            decoration: const InputDecoration(hintText: 'Escreva uma mensagem...', border: InputBorder.none),
            onSubmitted: (_) => _enviar())),
          IconButton.filled(onPressed: _enviando ? null : () => _enviar(),
            style: IconButton.styleFrom(backgroundColor: _rosa),
            icon: _enviando ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.arrow_upward_rounded)),
        ])),
    ])),
  );
}
