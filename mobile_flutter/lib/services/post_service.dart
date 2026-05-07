import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostService {

  static const String baseUrl =
      'http:192.168.1.218:8080';

  Future<List<Post>> listarPosts() async {

    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    final List lista =
    jsonDecode(response.body);

    return lista
        .map((e) => Post.fromJson(e))
        .toList();
  }

  Future<void> criarPost(
      Post post,
      ) async {

    await http.post(

      Uri.parse('$baseUrl/posts'),

      headers: {
        'Content-Type':
        'application/json',
      },

      body: jsonEncode(
        post.toJson(),
      ),
    );
  }
}