import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'api_service.dart';

class PostService {
  String get baseUrl => ApiService.baseUrl;

  Future<List<Post>> listarPosts({int? page, int size = 10}) async {
    final uri = page == null
        ? Uri.parse('$baseUrl/posts')
        : Uri.parse('$baseUrl/posts?page=$page&size=$size');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = data is List ? data : (data is Map ? data['content'] : null);
      if (lista is! List) throw const FormatException('Resposta inválida de posts');
      return lista.whereType<Map>().map((e) => Post.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('POSTS indisponíveis em $uri: $e');
      rethrow;
    }
  }

  Future<List<Post>> listarPostsPorUsuario(int idUsuario) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/usuario/$idUsuario'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = data is List ? data : (data is Map ? data['content'] : null);
      if (lista is! List) return [];
      return lista.whereType<Map>().map((e) => Post.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) { if (kDebugMode) debugPrint('Erro posts do usuário: $e'); return []; }
  }

  Future<bool> criarPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'},
        body: jsonEncode(post.toJson()),
      ).timeout(const Duration(seconds: 15));
      if (kDebugMode && ![200, 201].contains(response.statusCode)) {
        debugPrint('FALHA POST: ${response.statusCode} ${response.body}');
      }
      return [200, 201].contains(response.statusCode);
    } catch (e) { if (kDebugMode) debugPrint('Erro ao criar post: $e'); return false; }
  }

  Future<bool> deletarPost(int idPost, int idUsuario) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$idPost/usuario/$idUsuario'))
          .timeout(const Duration(seconds: 10));
      return [200, 204].contains(response.statusCode);
    } catch (e) { if (kDebugMode) debugPrint('Erro ao deletar post: $e'); return false; }
  }
}
