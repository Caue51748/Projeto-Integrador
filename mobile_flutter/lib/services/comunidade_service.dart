import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comunidade.dart';

class ComunidadeService {
  static const String baseUrl = 'http://localhost:8080';

  /// Lista todas as comunidades do banco
  Future<List<Comunidade>> listarComunidades() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/comunidades'));
      if (response.statusCode == 200) {
        final List lista =
            jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Comunidade.fromJson(e)).toList();
      }
    } catch (e) {
      print('Erro ao listar comunidades: $e');
    }
    return [];
  }

  /// Cria uma nova comunidade no backend
  Future<Comunidade?> criarComunidade({
    required String nome,
    required String descricao,
    required int criadorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comunidades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'descricao': descricao,
          'criadorId': criadorId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Comunidade.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      print('Erro ao criar comunidade: $e');
    }
    return null;
  }

  /// Adiciona o usuário como membro da comunidade
  Future<bool> participarComunidade(
      int idComunidade, int idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/comunidades/$idComunidade/participar/$idUsuario'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erro ao participar da comunidade: $e');
      return false;
    }
  }

  /// Remove o usuário como membro da comunidade
  Future<bool> sairComunidade(
      int idComunidade, int idMembro, int idSolicitante) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/comunidades/$idComunidade/membros/$idMembro/usuario/$idSolicitante'),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Erro ao sair da comunidade: $e');
      return false;
    }
  }
}
