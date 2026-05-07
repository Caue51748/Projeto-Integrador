// lib/screens/feed_page.dart

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'create_post_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() =>
      _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  final PostService service = PostService();

  List<Post> posts = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPosts();
  }

  Future<void> carregarPosts() async {

    posts = await service.listarPosts();

    setState(() {
      carregando = false;
    });
  }

  Future<void> deletar(int id) async {

    await service.deletarPost(id);

    carregarPosts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Feed'),
      ),

      floatingActionButton:
      FloatingActionButton(

        child: const Icon(Icons.add),

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const CreatePostPage(),
            ),
          );

          carregarPosts();
        },
      ),

      body: carregando
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : ListView.builder(

        itemCount: posts.length,

        itemBuilder: (context, index) {

          Post post = posts[index];

          return Card(

            child: ListTile(

              title: Text(post.titulo),

              subtitle: Text(post.conteudo),

              trailing: IconButton(

                icon: const Icon(Icons.delete),

                onPressed: () {
                  deletar(post.idPost!);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}