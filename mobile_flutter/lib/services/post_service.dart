// lib/services/post_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post.dart';
import 'api_service.dart';

class PostService {

  Future<List<Post>> listarPosts() async {

    final response = await http.get(
      Uri.parse(ApiService.posts),
    );

    if (response.statusCode == 200) {

      List lista = json.decode(response.body);

      return lista
          .map((e) => Post.fromJson(e))
          .toList();
    }

    throw Exception('Erro ao listar posts');
  }

  Future<void> criarPost(Post post) async {

    final response = await http.post(
      Uri.parse(ApiService.posts),
      headers: {
        'Content-Type': 'application/json'
      },
      body: json.encode(post.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Erro ao criar post');
    }
  }

  Future<void> deletarPost(int id) async {

    final response = await http.delete(
      Uri.parse('${ApiService.posts}/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar post');
    }
  }
}