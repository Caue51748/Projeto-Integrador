// lib/screens/create_post_page.dart

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() =>
      _CreatePostPageState();
}

class _CreatePostPageState
    extends State<CreatePostPage> {

  final tituloController =
  TextEditingController();

  final conteudoController =
  TextEditingController();

  final usuarioController =
  TextEditingController();

  final PostService service = PostService();

  Future<void> salvar() async {

    Post post = Post(

      titulo: tituloController.text,

      conteudo: conteudoController.text,

      idUsuario:
      int.parse(usuarioController.text),
    );

    await service.criarPost(post);

    Navigator.pop(context);
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

              decoration:
              const InputDecoration(
                labelText: 'Título',
              ),
            ),

            TextField(
              controller: conteudoController,

              decoration:
              const InputDecoration(
                labelText: 'Conteúdo',
              ),
            ),

            TextField(
              controller: usuarioController,

              keyboardType:
              TextInputType.number,

              decoration:
              const InputDecoration(
                labelText: 'ID Usuário',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: salvar,

              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}