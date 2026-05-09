// lib/screens/feed_page.dart

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comentario.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../services/usuario_service.dart';
import '../services/comentario_service.dart';
import 'login_screen.dart';
import 'create_post_page.dart';
import 'post_detail_screen.dart'; // Importa a tela nova

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
  Map<int, List<Comentario>> comentariosPorPost = {}; // Organiza os comentários por Post ID
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
      
      // Busca todos os comentários do banco para mostrar no feed
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

  // Navega para a nova tela de detalhes
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
      // Quando voltar da tela de detalhes, recarrega o feed para atualizar a quantidade de comentários
      carregarDados(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Feed", style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, size: 22), onPressed: carregarDados),
          if (!AuthService.logado)
            IconButton(
              icon: const Icon(Icons.login, size: 22),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                setState(() {});
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: irParaCriarPost,
        backgroundColor: Colors.black,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : posts.isEmpty
              ? const Center(child: Text("Nenhum post encontrado.", style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final nomeAutor = nomesUsuarios[post.idUsuario] ?? 'Desconhecido';
                    final inicial = nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : '?';
                    
                    // Pega os comentários desse post específico
                    final comentariosDoPost = comentariosPorPost[post.idPost] ?? [];
                    // Mostra só os 2 primeiros no feed
                    final previews = comentariosDoPost.take(2).toList(); 

                    return InkWell(
                      // Deixa o card inteiro clicável para abrir os detalhes
                      onTap: () => irParaDetalhes(post, nomeAutor), 
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              radius: 22,
                              child: Text(inicial, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nomeAutor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text(post.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(post.conteudo, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // --- SEÇÃO DE COMENTÁRIOS NO FEED ---
                                  if (previews.isNotEmpty) ...[
                                    for (var c in previews)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          "Ver todos os ${comentariosDoPost.length} comentários",
                                          style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                  ],

                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.favorite_border, color: Colors.grey, size: 18),
                                      const SizedBox(width: 24),
                                      const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                                      const SizedBox(width: 24),
                                      const Icon(Icons.share_outlined, color: Colors.grey, size: 18),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}