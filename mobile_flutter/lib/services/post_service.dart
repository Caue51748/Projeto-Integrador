import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  static const String baseUrl = 'http://192.168.1.218:8080';

  Future<List<Post>> listarPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
      );

      if (response.statusCode == 200) {
        // Usa utf8.decode para evitar problemas de acentuação no frontend
        final List lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Post.fromJson(e)).toList();
      }
    } catch (e) {
      print('Erro ao listar posts: $e');
    }
    return [];
  }

  // Agora retorna Future<bool> para a tela saber se deu certo
  Future<bool> criarPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(post.toJson()),
      );

      // Retorna true se o backend respondeu com sucesso (200 OK ou 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Erro backend: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao criar post: $e');
      return false;
    }
  }
}