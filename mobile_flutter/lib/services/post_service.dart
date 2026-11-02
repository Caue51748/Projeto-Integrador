import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'api_service.dart';

class PostService {
  String get baseUrl => ApiService.baseUrl;

  Future<List<Post>> listarPosts({int? page, int size = 10}) async {
    final uri = Uri.parse(page == null ? '$baseUrl/posts' : '$baseUrl/posts?page=$page&size=$size');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Não foi possível acessar posts (HTTP ${response.statusCode}).');
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final lista = data is List ? data : (data is Map ? data['content'] : null);
    if (lista is! List) throw const FormatException('API retornou um formato inesperado de posts.');
    return lista.whereType<Map>().map((p) => Post.fromJson(Map<String, dynamic>.from(p))).toList();
  }

  Future<List<Post>> listarPostsPorUsuario(int idUsuario) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/usuario/$idUsuario'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = data is List ? data : (data is Map ? data['content'] : null);
      return lista is List ? lista.whereType<Map>().map((p) => Post.fromJson(Map<String, dynamic>.from(p))).toList() : [];
    } catch (e) { if (kDebugMode) debugPrint('Posts do usuário: $e'); return []; }
  }

  Future<String> enviarImagem({required Uint8List bytes, required String nomeArquivo}) async {
    // CONTRATO NECESSÁRIO NO BACKEND: POST /posts/imagens (multipart campo "imagem")
    // -> {"url": "https://..."} ou {"imagemUrl": "..."}.
    // A API compartilhada não possuía este endpoint na documentação fornecida.
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts/imagens'));
    req.files.add(http.MultipartFile.fromBytes('imagem', bytes, filename: nomeArquivo));
    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('A API não aceitou o envio da imagem (HTTP ${response.statusCode}). É necessário implementar POST /posts/imagens no backend.');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is! Map) throw const FormatException('A API não devolveu a URL da imagem.');
    final url = (data['imagemUrl'] ?? data['url'] ?? data['imageUrl'])?.toString();
    if (url == null || url.trim().isEmpty) throw const FormatException('Resposta do upload sem URL da imagem.');
    return url;
  }

  Future<void> criarPostOuFalhar(Post post) async {
    final response = await http.post(Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type':'application/json; charset=UTF-8', 'Accept':'application/json'},
      body: jsonEncode(post.toJson())).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Não foi possível publicar (HTTP ${response.statusCode}): ${response.body.length > 150 ? response.body.substring(0,150) : response.body}');
    }
  }

  Future<bool> criarPost(Post post) async {
    try { await criarPostOuFalhar(post); return true; }
    catch (e) { if (kDebugMode) debugPrint('Criar post: $e'); return false; }
  }

  Future<bool> deletarPost(int idPost, int idUsuario) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$idPost/usuario/$idUsuario'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { if (kDebugMode) debugPrint('Deletar post: $e'); return false; }
  }
}
