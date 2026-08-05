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
      FocusScope.of(context).unfocus();
      await carregarComentarios();
    } else {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicialAutor = widget.nomeAutor.isNotEmpty ? widget.nomeAutor[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Publicação", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // POST PRINCIPAL CARD
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFFDF0F4),
                                radius: 22,
                                child: Text(
                                  inicialAutor,
                                  style: const TextStyle(color: Color(0xFFEA3F74), fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.nomeAutor,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    const Text('Autor da publicação', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.post.titulo,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.post.conteudo,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // SEÇÃO DE COMENTÁRIOS
                  Row(
                    children: [
                      const Icon(Icons.forum_outlined, color: Color(0xFFEA3F74), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Comentários (${comentarios.length})",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  carregando
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFFEA3F74))))
                      : comentarios.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                "Ainda não há comentários. Seja o primeiro a comentar!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comentarios.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final c = comentarios[index];
                                final nome = widget.nomesUsuarios[c.idUsuario] ?? "Desconhecido";
                                final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFFFDF0F4),
                                        radius: 16,
                                        child: Text(inicial, style: const TextStyle(color: Color(0xFFEA3F74), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 4),
                                            Text(c.conteudo, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
          
          // BARRA FIXA DE COMENTÁRIO
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Escreva um comentário...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEA3F74),
                    padding: const EdgeInsets.all(12),
                  ),
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