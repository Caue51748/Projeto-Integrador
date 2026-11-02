import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'api_service.dart';

class PostService {
  String get baseUrl => ApiService.baseUrl;

  // Mesma rota implementada no SocialJoinMediaController.java.
  // Mantemos --dart-define para ajustes sem editar código.
  static const String _uploadPathTemplate = String.fromEnvironment(
    'POST_IMAGE_UPLOAD_PATH', defaultValue: '/api/socialjoin-media/posts/{id}');
  static const String _uploadField = String.fromEnvironment(
    'POST_IMAGE_FIELD', defaultValue: 'imagem');

  Future<List<Post>> listarPosts({int? page, int size = 10}) async {
    final uri = Uri.parse(page == null
        ? '$baseUrl/posts'
        : '$baseUrl/posts?page=$page&size=$size');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Não foi possível buscar os posts (HTTP ${response.statusCode}).');
    }
    final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
    final dynamic lista = data is List ? data : (data is Map ? data['content'] : null);
    if (lista is! List) {
      throw const FormatException('A API não retornou uma lista de posts.');
    }
    final posts = lista.whereType<Map>().map((v) =>
        Post.fromJson(Map<String, dynamic>.from(v))).toList();
    return _comImagens(posts);
  }

  Future<List<Post>> listarPostsPorUsuario(int idUsuario) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/usuario/$idUsuario'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = data is List ? data : (data is Map ? data['content'] : null);
      if (lista is! List) return [];
      final posts = lista.whereType<Map>().map((v) =>
          Post.fromJson(Map<String, dynamic>.from(v))).toList();
      return _comImagens(posts);
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar posts do usuário: $e');
      return [];
    }
  }

  // Fonte nova e isolada, evitando conflito com GET /posts/imagens do Java antigo.
  static const String _listImagesPath = String.fromEnvironment(
    'POST_IMAGE_LIST_PATH', defaultValue: '/api/socialjoin-media/posts');

  Future<Map<int, List<String>>> listarImagensPosts() async {
    final imagens = <int, List<String>>{};
    // Preserva fotos que a implementação Web anterior já tivesse salvo.
    for (final caminho in <String>[_listImagesPath, '/posts/imagens']) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$caminho'))
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final dynamic lista = decoded is List ? decoded
          : (decoded is Map ? (decoded['content'] ?? decoded['imagens']) : null);
        if (lista is! List) continue;
        for (final raw in lista) {
          if (raw is! Map) continue;
          final rawId = raw['idPost'] ?? raw['id_post'] ?? raw['postId'];
          final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
          final url = raw['url'] ?? raw['imagemUrl'] ?? raw['caminho'];
          if (id == null || id <= 0 || url is! String || url.trim().isEmpty) continue;
          final destino = imagens.putIfAbsent(id, () => <String>[]);
          if (!destino.contains(url.trim())) destino.add(url.trim());
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Listagem de imagens ($caminho): $e');
      }
    }
    return imagens;
  }

  Future<List<Post>> _comImagens(List<Post> posts) async {
    try {
      final mapeamento = await listarImagensPosts();
      for (final post in posts) {
        final imagensDaApi = mapeamento[post.idPost] ?? const <String>[];
        if (imagensDaApi.isEmpty) continue;
        post.imagens = {...post.imagens, ...imagensDaApi}.toList();
        post.imagemUrl ??= post.imagens.first;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Imagens de posts não disponíveis: $e');
    }
    return posts;
  }

  // Retorna o ID real criado. Nunca inventa ID ou cria um segundo post
  // se a etapa de upload falhar.
  Future<int> criarPostRetornandoId(Post post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'},
      body: jsonEncode(post.toJson()),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao criar publicação (HTTP ${response.statusCode}): '
          '${_resumo(response.body)}');
    }
    if (response.body.trim().isEmpty) {
      throw const FormatException('O post foi criado, mas a API não devolveu seu ID. '
          'Verifique no feed antes de tentar publicar novamente.');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final data = decoded is Map ? decoded : null;
    final idRaw = data?['idPost'] ?? data?['id'] ??
        (data?['post'] is Map ? data!['post']['idPost'] : null);
    final id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw');
    if (id == null || id <= 0) {
      throw const FormatException('O post pode ter sido criado, mas a resposta não informou idPost. '
          'Confira o feed para evitar duplicação.');
    }
    return id;
  }

  Future<void> enviarImagemDoPost({
    required int idPost,
    required Uint8List bytes,
    required String nomeArquivo,
  }) async {
    final path = _uploadPathTemplate.replaceAll('{id}', '$idPost');
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes(
      _uploadField, bytes, filename: nomeArquivo));
    final streamed = await request.send().timeout(const Duration(seconds: 35));
    final response = await http.Response.fromStream(streamed);
    if (kDebugMode) {
      debugPrint('UPLOAD POST $idPost -> $uri: HTTP ${response.statusCode} ${_resumo(response.body)}');
    }
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      throw Exception('Upload da imagem falhou (HTTP ${response.statusCode}) em $path, '
          'campo "$_uploadField". Resposta: ${_resumo(response.body)}');
    }
  }

  static String _resumo(String texto) =>
      texto.length > 250 ? '${texto.substring(0, 250)}...' : texto;

  // Mantidos para não quebrar outras telas que já usam esses métodos.
  Future<void> criarPostOuFalhar(Post post) async {
    final response = await http.post(Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'},
      body: jsonEncode(post.toJson()),
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao publicar (HTTP ${response.statusCode}): ${_resumo(response.body)}');
    }
  }

  Future<bool> criarPost(Post post) async {
    try { await criarPostOuFalhar(post); return true; }
    catch (e) { if (kDebugMode) debugPrint('$e'); return false; }
  }

  Future<bool> deletarPost(int idPost, int idUsuario) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$idPost/usuario/$idUsuario'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) debugPrint('Deletar post: $e');
      return false;
    }
  }
}
