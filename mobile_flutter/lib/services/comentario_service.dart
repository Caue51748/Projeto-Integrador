import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/comentario.dart';
import 'api_service.dart';

class ComentarioService {
  String get baseUrl => ApiService.baseUrl;

  Future<List<Comentario>> listarComentarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comentarios'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Comentario.fromJson(e)).toList();
      } else {
        if (kDebugMode) print("Erro no servidor: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) print("ERRO AO BUSCAR COMENTÁRIOS: $e");
    }
    return [];
  }

  Future<bool> criarComentario(Comentario comentario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comentarios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(comentario.toJson()),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("ERRO AO CRIAR COMENTÁRIO: $e");
      return false;
    }
  }
}