import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../services/post_service.dart';
import '../services/api_service.dart';
import '../services/seguimento_service.dart';
import 'seguidores_page.dart';
import '../widgets/social_avatar.dart';
import 'chat_page.dart';
import 'post_detail_screen.dart';

/// Perfil público de outros usuários; sem opções de edição.
class PublicProfilePage extends StatefulWidget {
  final int usuarioId;
  const PublicProfilePage({super.key, required this.usuarioId});
  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  Usuario? _usuario;
  List<Post> _posts = [];
  ResumoSeguimentos? _resumo;
  bool _seguindoAgora = false;
  bool _salvandoSeguir = false;
  bool _loading = true;
  String? _erro;
  @override
  void initState() { super.initState(); _carregar(); }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final usuario = await UsuarioService().buscarPorId(widget.usuarioId);
      final posts = await PostService().listarPostsPorUsuario(widget.usuarioId);
      ResumoSeguimentos? resumo;
      try {
        resumo = await SeguimentoService().resumo(widget.usuarioId,
            solicitanteId: AuthService.idUsuario);
      } catch (_) { /* Perfil ainda carrega sem o módulo novo */ }
      if (!mounted) return;
      setState(() {
        _usuario = usuario;
        _posts = posts;
        _resumo = resumo;
        _seguindoAgora = resumo?.euSigo ?? false;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _erro = 'Não foi possível abrir o perfil: $e'; _loading = false; });
    }
  }

  Future<void> _alternarSeguir() async {
    final meuId = AuthService.idUsuario;
    if (meuId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre na sua conta para seguir pessoas.')));
      return;
    }
    if (_salvandoSeguir || meuId == widget.usuarioId) return;
    setState(() => _salvandoSeguir = true);
    try {
      final resumo = await SeguimentoService().alterar(
        meuId: meuId, outroId: widget.usuarioId, seguir: !_seguindoAgora);
      if (!mounted) return;
      setState(() { _resumo = resumo; _seguindoAgora = resumo.euSigo; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar: $e')));
    } finally {
      if (mounted) setState(() => _salvandoSeguir = false);
    }
  }

  Widget _contador(String label, int valor, bool seguidores) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => SeguidoresPage(usuarioId: widget.usuarioId, seguidores: seguidores))),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Column(children: [
        Text('$valor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF858B99))),
      ])),
  );

  void _mensagem() {
    if (_usuario == null) return;
    if (!AuthService.logado || AuthService.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para conversar.')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ConversaPage(usuario: _usuario!)));
  }

  @override
  Widget build(BuildContext context) {
    final u = _usuario;
    return Scaffold(backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: Text(u?.username == null ? 'Perfil' : '@${u!.username}'),
        backgroundColor: Colors.white),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
      _erro != null ? Center(child: Text(_erro!, textAlign: TextAlign.center)) :
      u == null ? const Center(child: Text('Usuário não encontrado.')) :
      RefreshIndicator(onRefresh: _carregar, child: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            SocialAvatar(nome: u.nome, foto: u.fotoPerfil, radius: 45),
            const SizedBox(height: 12),
            Text(u.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            if (u.username != null) Text('@${u.username}', style: const TextStyle(color: Color(0xFF898D9D))),
            if (u.bio != null && u.bio!.trim().isNotEmpty) ...[
              const SizedBox(height: 15), Text(u.bio!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Column(children: [
                Text('${_posts.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('posts', style: TextStyle(fontSize: 11, color: Color(0xFF858B99))),
              ])),
              _contador('seguidores', _resumo?.seguidores ?? 0, true),
              _contador('seguindo', _resumo?.seguindo ?? 0, false),
            ]),
            if (AuthService.idUsuario != widget.usuarioId) ...[
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: FilledButton.icon(
                  onPressed: _salvandoSeguir ? null : _alternarSeguir,
                  icon: Icon(_seguindoAgora ? Icons.check_rounded : Icons.person_add_alt_1_rounded),
                  label: Text(_seguindoAgora ? 'Seguindo' : 'Seguir'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEA3F74)))),
                const SizedBox(width: 9),
                Expanded(child: OutlinedButton.icon(onPressed: _mensagem,
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Mensagem'))),
              ]),
            ],
          ])),
        const SizedBox(height: 22),
        const Text('Publicações', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (_posts.isEmpty) const Padding(padding: EdgeInsets.all(20),
          child: Text('Nenhuma publicação ainda.')),
        ..._posts.map((p) => Card(color: Colors.white, elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: p, nomeAutor: u.nome,
                  nomesUsuarios: {widget.usuarioId: u.nome}))),
            child: Padding(padding: const EdgeInsets.all(16), child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                if (p.conteudo.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(p.conteudo, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (p.imagemUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(
                    ApiService.formatarUrlMidia(p.imagemUrl) ?? '',
                    height: 170, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink())),
                ],
              ])),
          ))),
      ])),
    );
  }
}
