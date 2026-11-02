import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/usuario_service.dart';
import '../services/api_service.dart';
import 'create_post_page.dart';
import 'post_detail_screen.dart';
import 'login_screen.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  static const roxo = Color(0xFFEA3F74);
  static const escuro = Color(0xFF171B2B);
  final _postService = PostService();
  final _usuarioService = UsuarioService();
  final ScrollController _scroll = ScrollController();
  final Map<int,String> _nomes = {};
  final Map<int,String?> _fotos = {};
  final Set<int> _curtidosLocal = {};
  List<Post> _posts = [];
  bool _loading = true;
  bool _maisLoading = false;
  bool _temMais = true;
  String? _erro;
  int _pagina = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels > _scroll.position.maxScrollExtent - 220) _carregarMais();
    });
    _carregar();
  }
  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  Future<void> _carregar() async {
    if (mounted) setState(() { _loading = true; _erro = null; });
    try {
      final posts = await _postService.listarPosts(page: 0, size: _pageSize);
      // A lista de usuários serve apenas para nomes e fotos. Uma falha nela não deve ocultar posts.
      List<Usuario> usuarios = [];
      try { usuarios = await _usuarioService.listarUsuarios(); } catch (_) {}
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _pagina = 1;
        _temMais = posts.length == _pageSize;
        _nomes.clear(); _fotos.clear();
        for (final u in usuarios) {
          if (u.idUsuario != null) { _nomes[u.idUsuario!] = u.nome; _fotos[u.idUsuario!] = u.fotoPerfil; }
        }
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _erro = 'Feed indisponível: $e'; _loading = false; });
    }
  }

  Future<void> _carregarMais() async {
    if (_maisLoading || !_temMais || _loading) return;
    _maisLoading = true;
    try {
      final lista = await _postService.listarPosts(page: _pagina, size: _pageSize);
      if (mounted) {
        setState(() {
          final ids = _posts.map((p) => p.idPost).toSet();
          final unicos = lista.where((p) => !ids.contains(p.idPost)).toList();
          _posts.addAll(unicos);
          _pagina++;
          _temMais = lista.length == _pageSize && unicos.isNotEmpty;
        });
      }
    } catch (e) { if (mounted) setState(() => _temMais = false); }
    finally { _maisLoading = false; }
  }

  Future<void> _criar() async {
    if (!AuthService.logado) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final salvou = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()));
    if (salvou == true) _carregar();
  }

  void _detalhes(Post post) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(
      post: post, nomeAutor: _nomes[post.idUsuario] ?? 'Membro', nomesUsuarios: _nomes,
    ))).then((_) => _carregar());
  }

  Widget _avatar(String nome, String? foto, {double size = 22}) {
    final url = ApiService.formatarUrlFotoPerfil(foto);
    return CircleAvatar(radius: size, backgroundColor: const Color(0xFFFFEAF1),
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null ? Text(nome.isEmpty ? '?' : nome[0].toUpperCase(),
        style: const TextStyle(color: roxo, fontWeight: FontWeight.w900)) : null);
  }

  Widget _card(Post post) {
    final autor = _nomes[post.idUsuario] ?? 'Membro da comunidade';
    final imagem = ApiService.formatarUrlMidia(post.imagemUrl);
    final foto = _fotos[post.idUsuario];
    return Container(margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.fromLTRB(15,14,15,12), child: Row(children: [
          _avatar(autor, foto, size: 21),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(autor, style: const TextStyle(color: escuro, fontWeight: FontWeight.w800)),
            const Text('Comunidade SocialJoin', style: TextStyle(color: Color(0xFF8A90A1), fontSize: 11)),
          ])),
          const Icon(Icons.more_horiz_rounded, color: Color(0xFF858B9B)),
        ])),
        InkWell(onTap: () => _detalhes(post), child: Padding(
          padding: const EdgeInsets.fromLTRB(15,4,15,14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
              color: escuro, letterSpacing: -.35)),
            const SizedBox(height: 8),
            Text(post.conteudo, maxLines: 6, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF4E5669), height: 1.55, fontSize: 14)),
          ]))),
        if (imagem != null) GestureDetector(onTap: () => _detalhes(post),
          child: Image.network(imagem, fit: BoxFit.cover, width: double.infinity,
            height: 230, errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(20), child: Text('Imagem indisponível')))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [
          TextButton.icon(onPressed: () {
            // Curtidas apenas visuais: não existe endpoint de curtidas na API fornecida.
            if (post.idPost == null) return;
            setState(() {
              if (!_curtidosLocal.remove(post.idPost)) _curtidosLocal.add(post.idPost!);
            });
          }, icon: Icon(_curtidosLocal.contains(post.idPost) ? Icons.favorite : Icons.favorite_border_rounded,
            color: _curtidosLocal.contains(post.idPost) ? const Color(0xFFED4769) : const Color(0xFF8790A0), size: 21),
            label: const Text('Curtir')),
          TextButton.icon(onPressed: () => _detalhes(post),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20), label: const Text('Comentar')),
          const Spacer(),
          IconButton(onPressed: () => _detalhes(post), tooltip: 'Abrir publicação',
            icon: const Icon(Icons.arrow_outward_rounded, color: Color(0xFF8790A0))),
        ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _criar, icon: const Icon(Icons.edit_square), label: const Text('Publicar')),
    body: _loading ? const Center(child: CircularProgressIndicator()) :
      _erro != null ? Center(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: roxo),
          const SizedBox(height: 16), Text(_erro!, textAlign: TextAlign.center),
          const SizedBox(height: 16), FilledButton(onPressed: _carregar, child: const Text('Tentar novamente')),
        ]))) : RefreshIndicator(onRefresh: _carregar,
        child: ListView.builder(controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16,18,16,100),
          itemCount: _posts.length + 1 + (_maisLoading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Feed', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800,
                letterSpacing: -.8, color: escuro)),
              const SizedBox(height: 4),
              const Text('Descubra e compartilhe momentos da comunidade.',
                style: TextStyle(color: Color(0xFF858B9B))),
              const SizedBox(height: 18),
              Material(color: Colors.white, borderRadius: BorderRadius.circular(20),
                child: InkWell(borderRadius: BorderRadius.circular(20), onTap: _criar,
                  child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                    _avatar(AuthService.nomeUsuario ?? 'Você', AuthService.fotoPerfil),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Compartilhe uma novidade...',
                      style: TextStyle(color: Color(0xFF808798)))),
                    const Icon(Icons.add_photo_alternate_outlined, color: roxo),
                  ])))),
              const SizedBox(height: 22),
              if (_posts.isNotEmpty) const Text('Publicações recentes', style: TextStyle(
                fontSize: 18, color: escuro, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              if (_posts.isEmpty) const Padding(padding: EdgeInsets.all(30),
                child: Center(child: Text('Ainda não há publicações. Crie a primeira!'))),
              ]);
            }
            if (i > _posts.length) {
              return const Padding(padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()));
            }
            return _card(_posts[i-1]);
          },
        )),
  );
}
