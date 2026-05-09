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

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PostService postService = PostService();
  final UsuarioService usuarioService = UsuarioService();
  
  List<Post> posts = [];
  Map<int, String> nomesUsuarios = {};
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
      
      Map<int, String> mapa = {};
      for (var u in listaUsuarios) {
        if (u.idUsuario != null) {
          mapa[u.idUsuario!] = u.nome;
        }
      }

      final listaPosts = await postService.listarPosts();
      
      setState(() {
        nomesUsuarios = mapa;
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

  // FUNÇÃO NOVA: Abre a gaveta de comentários na parte de baixo da tela
  void abrirComentarios(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que a tela ocupe mais espaço (para o teclado não cobrir)
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ComentariosBottomSheet(
        idPost: post.idPost ?? 0, // Substitua por post.id se estiver dando erro de nome
        nomesUsuarios: nomesUsuarios,
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: carregarDados, 
          ),
          if (!AuthService.logado)
            IconButton(
              icon: const Icon(Icons.login, size: 22),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
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
              ? const Center(
                  child: Text("Nenhum post encontrado.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final nomeAutor = nomesUsuarios[post.idUsuario] ?? 'Desconhecido';
                    final inicial = nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : '?';

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            radius: 22,
                            child: Text(
                              inicial,
                              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nomeAutor,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  post.titulo,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  post.conteudo,
                                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.favorite_border, color: Colors.grey, size: 18),
                                    const SizedBox(width: 24),
                                    // AQUI: Tornamos o ícone de comentário clicável
                                    GestureDetector(
                                      onTap: () => abrirComentarios(context, post),
                                      child: const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                                    ),
                                    const SizedBox(width: 24),
                                    const Icon(Icons.share_outlined, color: Colors.grey, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ----------------------------------------------------------------------
// GAVETA DE COMENTÁRIOS (Bottom Sheet) 
// Adicionado no final do arquivo para manter tudo organizado na mesma tela
// ----------------------------------------------------------------------

class ComentariosBottomSheet extends StatefulWidget {
  final int idPost;
  final Map<int, String> nomesUsuarios;

  const ComentariosBottomSheet({
    super.key,
    required this.idPost,
    required this.nomesUsuarios,
  });

  @override
  State<ComentariosBottomSheet> createState() => _ComentariosBottomSheetState();
}

class _ComentariosBottomSheetState extends State<ComentariosBottomSheet> {
  final ComentarioService comentarioService = ComentarioService();
  final TextEditingController controller = TextEditingController();
  
  List<Comentario> comentarios = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarComentarios();
  }

  Future<void> carregarComentarios() async {
    setState(() => carregando = true);
    try {
      final lista = await comentarioService.listarComentarios();
      setState(() {
        // Filtra para mostrar APENAS os comentários que pertencem a este post
        comentarios = lista.where((c) => c.idPost == widget.idPost).toList();
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  Future<void> enviarComentario() async {
    if (controller.text.trim().isEmpty) return;
    
    if (!AuthService.logado || AuthService.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa fazer login para comentar!')),
      );
      return;
    }

    final novo = Comentario(
      conteudo: controller.text,
      idUsuario: AuthService.idUsuario!,
      idPost: widget.idPost,
    );

    setState(() => carregando = true);
    final sucesso = await comentarioService.criarComentario(novo);
    
    if (sucesso) {
      controller.clear();
      await carregarComentarios();
    } else {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega o espaço do teclado para a gaveta subir junto com ele
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6 + keyboardHeight,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        children: [
          // Tracinho no topo da gaveta
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text("Comentários", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          
          // Lista de Comentários
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : comentarios.isEmpty
                    ? const Center(child: Text("Ainda não há comentários.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: comentarios.length,
                        itemBuilder: (context, index) {
                          final c = comentarios[index];
                          final nome = widget.nomesUsuarios[c.idUsuario] ?? "Desconhecido";
                          final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              radius: 16,
                              child: Text(inicial, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(nome, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: Text(c.conteudo, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          );
                        },
                      ),
          ),
          
          // Campo de Digitação do Comentário
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Adicionar um comentário...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: enviarComentario,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}