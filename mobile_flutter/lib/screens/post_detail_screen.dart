// lib/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comentario.dart';
import '../services/auth_service.dart';
import '../services/comentario_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final String nomeAutor;
  final Map<int, String> nomesUsuarios;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.nomeAutor,
    required this.nomesUsuarios,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
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
        comentarios = lista.where((c) => c.idPost == widget.post.idPost).toList();
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
      idPost: widget.post.idPost ?? 0,
    );

    setState(() => carregando = true);
    final sucesso = await comentarioService.criarComentario(novo);
    
    if (sucesso) {
      controller.clear();
      FocusScope.of(context).unfocus(); // Esconde o teclado
      await carregarComentarios();
    } else {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicialAutor = widget.nomeAutor.isNotEmpty ? widget.nomeAutor[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Post", style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // POST PRINCIPAL
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        radius: 22,
                        child: Text(inicialAutor, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Text(widget.nomeAutor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.post.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(widget.post.conteudo, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),
                  
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 16),

                  // LISTA DE COMENTÁRIOS
                  const Text("Comentários", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  carregando
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black)))
                      : comentarios.isEmpty
                          ? const Text("Ainda não há comentários. Seja o primeiro!", style: TextStyle(color: Colors.grey))
                          : ListView.separated(
                              shrinkWrap: true, // Importante para não dar erro de layout dentro do ScrollView
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comentarios.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final c = comentarios[index];
                                final nome = widget.nomesUsuarios[c.idUsuario] ?? "Desconhecido";
                                final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[100],
                                      radius: 16,
                                      child: Text(inicial, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text(c.conteudo, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
          
          // CAMPO DE DIGITAR COMENTÁRIO FIXO NO RODAPÉ
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8, // Respeita a área inferior do iPhone/Android
            ),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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