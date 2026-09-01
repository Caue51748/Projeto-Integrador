import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../models/comentario.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/usuario_service.dart';
import '../services/comentario_service.dart';
import 'login_screen.dart';
import 'create_post_page.dart';
import 'post_detail_screen.dart';

/// Feed Social Mobile — Fiel à Estilização Real da Tela WEB (.card, .post-card, .avatar, .feed-tab, .post-action).
/// Fonte da Verdade: web/style.css
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
      backgroundColor: const Color(0xFFF7F8FA),
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
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          "Novo Post",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: posts.length + 1,
                itemBuilder: (context, index) {
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

                  return _buildWebStylePostCard(
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

  /// Caixa Superior Fiel ao Estilo `.card` da Web
  Widget _buildInlineCreatePostCard() {
    final nomeUsuario = AuthService.logado
        ? (AuthService.nomeUsuario ?? 'Usuário')
        : 'Visitante';
    final inicial = nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(17, 24, 39, 0.07),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar (.avatar da Web)
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEA3F74),
            child: Text(
              inicial,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  'No que você está pensando, $nomeUsuario?',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card de Post Fiel aos componentes `.card`, `.post-card`, `.post-header-area`, `.post-actions` da Web CSS
  Widget _buildWebStylePostCard({
    required Post post,
    required String nomeAutor,
    required String inicial,
    required int qtdComentarios,
    required bool curtiu,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(17, 24, 39, 0.07),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => irParaDetalhes(post, nomeAutor),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Area (.post-header-area da Web)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEA3F74),
                      child: Text(
                        inicial,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomeAutor,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF202124),
                            ),
                          ),
                          Text(
                            'Publicação',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Título do Post (.post-title da Web)
                Text(
                  post.titulo,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202124),
                  ),
                ),

                const SizedBox(height: 8),

                // Conteúdo do Post (.post-body da Web)
                Text(
                  post.conteudo,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Barra de Ações (.post-actions e .post-action da Web CSS)
                Container(
                  padding: const EdgeInsets.only(top: 11),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Curtida / Like
                      InkWell(
                        onTap: () {
                          if (post.idPost != null) {
                            _toggleCurtida(post.idPost!);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                          decoration: BoxDecoration(
                            color: curtiu ? const Color(0xFFF7F8FA) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                curtiu ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: curtiu ? const Color(0xFFEA3F74) : const Color(0xFF6B7280),
                                size: 19,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                curtiu ? '1' : '0',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: curtiu ? const Color(0xFFEA3F74) : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Comentários
                      InkWell(
                        onTap: () => irParaDetalhes(post, nomeAutor),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Color(0xFF6B7280),
                                size: 19,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$qtdComentarios',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Botão Abrir (.post-open-button da Web)
                      InkWell(
                        onTap: () => irParaDetalhes(post, nomeAutor),
                        child: Row(
                          children: [
                            Text(
                              'Ver detalhes',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFEA3F74),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, color: Color(0xFFEA3F74), size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}