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
      Map<int, String> mapaUsuarios = {for (var u in listaUsuarios) if (u.idUsuario != null) u.idUsuario!: u.nome};
      final listaPosts = await postService.listarPosts();
      final listaComentarios = await comentarioService.listarComentarios();
      
      Map<int, List<Comentario>> mapaComentarios = {};
      for (var c in listaComentarios) {
        mapaComentarios.putIfAbsent(c.idPost, () => []).add(c);
      }
      
      setState(() {
        nomesUsuarios = mapaUsuarios;
        comentariosPorPost = mapaComentarios;
        posts = listaPosts.reversed.toList();
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  void irParaDetalhes(Post post, String nomeAutor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post, nomeAutor: nomeAutor, nomesUsuarios: nomesUsuarios)),
    ).then((_) => carregarDados());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Usa o fundo do MaterialApp (F4F6F8)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!AuthService.logado) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
             return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage())).then((_) => carregarDados());
        },
        backgroundColor: const Color(0xFFEA3F74),
        elevation: 4,
        icon: const Icon(Icons.edit_square, color: Colors.white, size: 20),
        label: const Text("Novo Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA3F74)))
          : RefreshIndicator(
              onRefresh: carregarDados,
              color: const Color(0xFFEA3F74),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final nomeAutor = nomesUsuarios[post.idUsuario] ?? 'Desconhecido';
                  final qtdComentarios = comentariosPorPost[post.idPost]?.length ?? 0;
                  final inicial = nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : '?';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Cantos bem arredondados
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04), // Sombra muito suave, apenas para destacar
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => irParaDetalhes(post, nomeAutor),
                      child: Padding(
                        padding: const EdgeInsets.all(20), // Respiro interno maior
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header do Usuário
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFFDF0F4), // Fundo do avatar em rosa claro
                                  child: Text(
                                    inicial, 
                                    style: const TextStyle(color: Color(0xFFEA3F74), fontWeight: FontWeight.bold, fontSize: 18)
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nomeAutor,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                                      ),
                                      Text(
                                        "Membro da comunidade", // Subtom sutil
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Conteúdo Principal
                            Text(
                              post.titulo, 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.conteudo, 
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                            ),
                            
                            const SizedBox(height: 20),
                            Divider(color: Colors.grey.shade100, height: 1),
                            const SizedBox(height: 12),

                            // Ações
                            Row(
                              children: [
                                _buildActionButton(Icons.favorite_border_rounded, "Curtir"),
                                const SizedBox(width: 24),
                                _buildActionButton(Icons.chat_bubble_outline_rounded, "$qtdComentarios Comentários"),
                                const Spacer(),
                                Icon(Icons.ios_share_rounded, color: Colors.grey.shade400, size: 22),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Widget padronizado para os botões do rodapé do post
  Widget _buildActionButton(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        const SizedBox(width: 6),
        Text(
          text, 
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}