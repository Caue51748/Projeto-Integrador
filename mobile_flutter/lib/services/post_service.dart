import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostService {

  static const String baseUrl =
      "http://192.168.1.218:8080/posts";

  Future<List<Post>> listarPosts() async {

    final response = await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode == 200) {

      List jsonResponse =
      json.decode(response.body);

      return jsonResponse
          .map((p) => Post.fromJson(p))
          .toList();

    } else {

      throw Exception(
        "Erro ao listar posts",
      );
    }
  }

  Future<void> criarPost(
      Post post
      ) async {

    final response = await http.post(

      Uri.parse(baseUrl),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode(
        post.toJson(),
      ),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {

      throw Exception(
        "Erro ao criar post",
      );
    }
  }
}