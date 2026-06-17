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
      Map<int, String> mapaUsuarios = {};
      for (var u in listaUsuarios) {
        if (u.idUsuario != null) mapaUsuarios[u.idUsuario!] = u.nome;
      }

      final listaPosts = await postService.listarPosts();
      
      final listaComentarios = await comentarioService.listarComentarios();
      Map<int, List<Comentario>> mapaComentarios = {};
      
      for (var c in listaComentarios) {
        if (!mapaComentarios.containsKey(c.idPost)) {
          mapaComentarios[c.idPost] = [];
        }
        mapaComentarios[c.idPost]!.add(c);
      }
      
      setState(() {
        nomesUsuarios = mapaUsuarios;
        comentariosPorPost = mapaComentarios;
        posts = listaPosts.reversed.toList();
        carregando = false;
      });
    } catch (e) {
      print(e);
      setState(() => carregando = false);
    }
  }

  Future<void> irParaCriarPost() async {
    if (!AuthService.logado) {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (resultado != true) return;
    }

    final bool? postCriado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );

    if (postCriado == true) carregarDados();
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
    ).then((_) {
      carregarDados(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Fundo Cinza estilo site
      appBar: AppBar(
        title: const Text("Explorar"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded), 
            onPressed: carregarDados,
            color: Colors.grey.shade700,
          ),
          if (!AuthService.logado)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                icon: const Icon(Icons.login, size: 20),
                label: const Text("Entrar"),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFEA3F74)),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  setState(() {});
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: irParaCriarPost,
        backgroundColor: const Color(0xFFEA3F74), // Botão na sua cor principal
        elevation: 3,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Novo Evento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA3F74)))
          : posts.isEmpty
              ? const Center(child: Text("Nenhum post encontrado.", style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 80),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final nomeAutor = nomesUsuarios[post.idUsuario] ?? 'Desconhecido';
                    final inicial = nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : '?';
                    
                    final comentariosDoPost = comentariosPorPost[post.idPost] ?? [];
                    final previews = comentariosDoPost.take(2).toList(); 

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => irParaDetalhes(post, nomeAutor), 
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFFFABC5).withOpacity(0.4), // Subtom aqui
                                    radius: 20,
                                    child: Text(inicial, style: const TextStyle(color: Color(0xFFEA3F74), fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nomeAutor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                                        Text("Há poucas horas", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.more_horiz, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(post.titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87)),
                              const SizedBox(height: 6),
                              Text(post.conteudo, style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5)),
                              
                              const SizedBox(height: 16),
                              
                              if (previews.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F4F7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var c in previews)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                                              children: [
                                                TextSpan(
                                                  text: "${nomesUsuarios[c.idUsuario] ?? 'Desconhecido'} ",
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                TextSpan(text: c.conteudo),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (comentariosDoPost.length > 2)
                                        Text(
                                          "Ver todos os ${comentariosDoPost.length} comentários",
                                          style: const TextStyle(color: Color(0xFFEA3F74), fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              Divider(color: Colors.grey.shade100, height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildAcaoPost(Icons.favorite_border, "Curtir"),
                                  _buildAcaoPost(Icons.chat_bubble_outline, "${comentariosDoPost.length} Comentários"),
                                  _buildAcaoPost(Icons.share_outlined, "Compartilhar"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Widget para os botões de ação do post ficarem bonitos
  Widget _buildAcaoPost(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}