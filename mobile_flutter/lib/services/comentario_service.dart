// lib/services/comentario_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comentario.dart';

class ComentarioService {
  static const String baseUrl = 'http://192.168.1.218:8080';

  Future<List<Comentario>> listarComentarios() async {
    final response = await http.get(Uri.parse('$baseUrl/comentarios'));

    if (response.statusCode == 200) {
      final List lista = jsonDecode(response.body);
      return lista.map((e) => Comentario.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> criarComentario(Comentario comentario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comentarios'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(comentario.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}