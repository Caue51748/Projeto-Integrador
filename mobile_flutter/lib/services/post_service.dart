import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Post>> listarPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        final List lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Post.fromJson(e)).toList();
      }
    } catch (e) {
      print('Erro ao listar posts: $e');
    }
    return [];
  }

  Future<bool> criarPost(Post post) async {
    try {
      // 1. Converte para JSON e mostra no console do VS Code o que está sendo enviado
      final corpoJson = jsonEncode(post.toJson());
      print('=== ENVIANDO POST PARA O BACKEND ===');
      print('URL: $baseUrl/posts');
      print('Corpo: $corpoJson');

      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: corpoJson,
      );

      // 2. Mostra no console do VS Code a resposta exata do Spring Boot
      print('=== RESPOSTA DO BACKEND ===');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Sucesso!
      } else {
        return false; // Falha (Backend recusou)
      }
    } catch (e) {
      print('=== ERRO GRAVE DE REDE ===');
      print('O Flutter não conseguiu falar com o servidor: $e');
      return false; // Falha (Erro de conexão)
    }
  }
}