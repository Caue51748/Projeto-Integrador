import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comentario.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/usuario_service.dart';
import '../services/comentario_service.dart';
import 'login_screen.dart';
import 'create_post_page.dart';
import 'post_detail_screen.dart';

/// Feed Social da Versão Mobile com Redesign Estilo Reddit & Twitter.
/// Focado em legibilidade de conteúdo, hierarquia visual moderna e botões em pílulas (Pill Bar).
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PostService postService = PostService();
  final UsuarioService usuarioService = UsuarioService();
  final ComentarioService comentarioService = ComentarioService();

  List<Post> posts = [];
  Map<int, String> nomesUsuarios = {};
  Map<int, List<Comentario>> comentariosPorPost = {};
  Set<int> postsCurtidos = {};
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => carregando = true);
    try {
      final listaUsuarios = await usuarioService.listarUsuarios();
      Map<int, String> mapaUsuarios = {
        for (var u in listaUsuarios)
          if (u.idUsuario != null) u.idUsuario!: u.nome
      };
      final listaPosts = await postService.listarPosts();
      final listaComentarios = await comentarioService.listarComentarios();

      Map<int, List<Comentario>> mapaComentarios = {};
      for (var c in listaComentarios) {
        mapaComentarios.putIfAbsent(c.idPost, () => []).add(c);
      }

      if (mounted) {
        setState(() {
          nomesUsuarios = mapaUsuarios;
          comentariosPorPost = mapaComentarios;
          posts = listaPosts.reversed.toList();
          carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  void irParaDetalhes(Post post, String nomeAutor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          nomeAutor: nomeAutor,
          nomesUsuarios: nomesUsuarios,
        ),
      ),
    ).then((_) => carregarDados());
  }

  void _toggleCurtida(int postId) {
    setState(() {
      if (postsCurtidos.contains(postId)) {
        postsCurtidos.remove(postId);
      } else {
        postsCurtidos.add(postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!AuthService.logado) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          ).then((_) => carregarDados());
        },
        backgroundColor: const Color(0xFFEA3F74),
        elevation: 4,
        icon: const Icon(Icons.edit_square, color: Colors.white, size: 18),
        label: const Text(
          "Novo Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEA3F74)),
            )
          : RefreshIndicator(
              onRefresh: carregarDados,
              color: const Color(0xFFEA3F74),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                itemCount: posts.length + 1,
                itemBuilder: (context, index) {
                  // Widget inline superior para criar post estilo Reddit
                  if (index == 0) {
                    return _buildInlineCreatePostCard();
                  }

                  final post = posts[index - 1];
                  final nomeAutor =
                      nomesUsuarios[post.idUsuario] ?? 'Desconhecido';
                  final qtdComentarios =
                      comentariosPorPost[post.idPost]?.length ?? 0;
                  final inicial =
                      nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : '?';
                  final bool curtiu =
                      post.idPost != null && postsCurtidos.contains(post.idPost!);

                  return _buildRedditPostCard(
                    post: post,
                    nomeAutor: nomeAutor,
                    inicial: inicial,
                    qtdComentarios: qtdComentarios,
                    curtiu: curtiu,
                  );
                },
              ),
            ),
    );
  }

  /// Caixa superior inspirada no Reddit ("No que você está pensando?")
  Widget _buildInlineCreatePostCard() {
    final nomeUsuario = AuthService.logado
        ? (AuthService.nomeUsuario ?? 'Usuário')
        : 'Visitante';
    final inicial = nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFDF0F4),
            child: Text(
              inicial,
              style: const TextStyle(
                color: Color(0xFFEA3F74),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                if (!AuthService.logado) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostPage()),
                ).then((_) => carregarDados());
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Text(
                  'No que você está pensando?',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.image_outlined,
                color: Color(0xFFEA3F74), size: 22),
            onPressed: () {
              if (!AuthService.logado) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostPage()),
              ).then((_) => carregarDados());
            },
          ),
        ],
      ),
    );
  }

  /// Card de post no padrão Reddit & Twitter/X
  Widget _buildRedditPostCard({
    required Post post,
    required String nomeAutor,
    required String inicial,
    required int qtdComentarios,
    required bool curtiu,
  }) {
    final handle = '@${nomeAutor.toLowerCase().replaceAll(' ', '')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => irParaDetalhes(post, nomeAutor),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do Autor (Estilo Reddit/Twitter)
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFFDF0F4),
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        color: Color(0xFFEA3F74),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                nomeAutor,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              handle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'r/SocialJoin • há 2h',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tag de Categoria
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '💬 Post',
                      style: TextStyle(
                        color: Color(0xFFEA3F74),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Título do Post
              Text(
                post.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              // Conteúdo do Post
              Text(
                post.conteudo,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.45,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 14),

              // Barra de Cápsulas de Ação (Reddit Pill Bar)
              Row(
                children: [
                  // Cápsula de Upvote / Curtida
                  InkWell(
                    onTap: () {
                      if (post.idPost != null) {
                        _toggleCurtida(post.idPost!);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: curtiu
                            ? const Color(0xFFFDF0F4)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: curtiu
                              ? const Color(0xFFF9ACC6)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            curtiu
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: curtiu
                                ? const Color(0xFFEA3F74)
                                : const Color(0xFF64748B),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            curtiu ? '1' : '0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: curtiu
                                  ? const Color(0xFFEA3F74)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Cápsula de Comentários
                  InkWell(
                    onTap: () => irParaDetalhes(post, nomeAutor),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF64748B),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$qtdComentarios ${qtdComentarios == 1 ? 'comentário' : 'comentários'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Botão Compartilhar
                  IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Color(0xFF64748B), size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link do post copiado!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: 'Compartilhar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}