import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import 'login_screen.dart';
import 'create_post_page.dart'; // Importação da sua tela de criar post

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
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
    setState(() {
      carregando = true;
    });
    try {
      final lista = await service.listarPosts();
      setState(() {
        posts = lista.reversed.toList(); // Exibe os mais novos primeiro
        carregando = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> irParaCriarPost() async {
    // Se não estiver logado, obriga a logar
    if (!AuthService.logado) {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      // Se cancelou o login, para por aqui
      if (resultado != true) {
        return;
      }
    }

    // Navega para a tela de criar post e espera ela fechar
    final bool? postCriado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );

    // Se o CreatePostPage retornar 'true', recarrega o banco
    if (postCriado == true) {
      carregarPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarPosts, // Botão para forçar atualização do feed
          ),
          if (!AuthService.logado)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
                setState(() {});
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: irParaCriarPost, // Chama a função que leva para a outra tela
        child: const Icon(Icons.add),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : posts.isEmpty
              ? const Center(child: Text("Nenhum post encontrado."))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          post.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(post.conteudo),
                      ),
                    );
                  },
                ),
    );
  }
}