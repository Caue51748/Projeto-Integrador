import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

import 'login_screen.dart';

class FeedPage extends StatefulWidget {

  const FeedPage({super.key});

  @override
  State<FeedPage> createState() =>
      _FeedPageState();
}

class _FeedPageState
    extends State<FeedPage> {

  final PostService service =
      PostService();

  List<Post> posts = [];

  bool carregando = true;

  final tituloController =
  TextEditingController();

  final conteudoController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    carregarPosts();
  }

  Future<void> carregarPosts() async {

    try {

      final lista =
      await service.listarPosts();

      setState(() {

        posts = lista;
        carregando = false;
      });

    } catch (e) {

      print(e);

      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> criarPost() async {

    if (!AuthService.logado) {

      final resultado =
      await Navigator.push(

        context,

        MaterialPageRoute(
          builder: (_) =>
          const LoginScreen(),
        ),
      );

      if (resultado != true) {
        return;
      }
    }

    try {

      Post post = Post(

        titulo:
        tituloController.text,

        conteudo:
        conteudoController.text,

        idUsuario:
        AuthService.idUsuario!,
      );

      await service.criarPost(post);

      tituloController.clear();
      conteudoController.clear();

      Navigator.pop(context);

      carregarPosts();

    } catch (e) {

      print(e);
    }
  }

  void abrirFormulario() {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
          const Text("Novo Post"),

          content: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              TextField(

                controller:
                tituloController,

                decoration:
                const InputDecoration(
                  labelText:
                  "Título",
                ),
              ),

              TextField(

                controller:
                conteudoController,

                decoration:
                const InputDecoration(
                  labelText:
                  "Conteúdo",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child:
              const Text("Cancelar"),
            ),

            ElevatedButton(

              onPressed: criarPost,

              child:
              const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Feed",
        ),

        actions: [

          if (!AuthService.logado)

            IconButton(

              icon:
              const Icon(Icons.login),

              onPressed: () async {

                await Navigator.push(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                    const LoginScreen(),
                  ),
                );

                setState(() {});
              },
            ),
        ],
      ),

      floatingActionButton:
      FloatingActionButton(

        onPressed: abrirFormulario,

        child:
        const Icon(Icons.add),
      ),

      body: carregando

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : ListView.builder(

        itemCount: posts.length,

        itemBuilder:
            (context, index) {

          final post =
          posts[index];

          return Card(

            margin:
            const EdgeInsets.all(8),

            child: ListTile(

              title:
              Text(post.titulo),

              subtitle:
              Text(post.conteudo),
            ),
          );
        },
      ),
    );
  }
}