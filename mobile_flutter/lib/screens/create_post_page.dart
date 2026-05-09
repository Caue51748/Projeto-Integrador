// lib/screens/create_post_page.dart

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart'; // Importante para pegar o ID automático

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final tituloController = TextEditingController();
  final conteudoController = TextEditingController();
  final PostService service = PostService();
  bool salvando = false; // Controle para mostrar barra de loading

  Future<void> salvar() async {
    // Trava de segurança extra
    if (!AuthService.logado || AuthService.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não está logado!')),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    Post post = Post(
      titulo: tituloController.text,
      conteudo: conteudoController.text,
      idUsuario: AuthService.idUsuario, // Pega AUTOMATICAMENTE do AuthService
    );

    bool sucesso = await service.criarPost(post);

    setState(() {
      salvando = false;
    });

    if (sucesso) {
      // Retorna "true" para o Feed saber que a tela fechou com sucesso e precisa atualizar a lista
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao salvar no banco de dados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
            ),
            TextField(
              controller: conteudoController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
              ),
            ),
            const SizedBox(height: 20),
            salvando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: salvar,
                    child: const Text('Publicar'),
                  ),
          ],
        ),
      ),
    );
  }
}