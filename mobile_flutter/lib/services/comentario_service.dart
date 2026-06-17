import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comentario.dart';

class ComentarioService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Comentario>> listarComentarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comentarios'));

      if (response.statusCode == 200) {
        final List lista = jsonDecode(response.body);
        return lista.map((e) => Comentario.fromJson(e)).toList();
      } else {
        print("Erro no servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("ERRO AO BUSCAR COMENTÁRIOS: $e");
    }
    return [];
  }

  Future<bool> criarComentario(Comentario comentario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comentarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(comentario.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERRO AO CRIAR COMENTÁRIO: $e");
      return false;
    }
  }
}