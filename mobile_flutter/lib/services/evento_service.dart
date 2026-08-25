import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/evento.dart';
import 'api_service.dart';

class EventoService {
  String get baseUrl => ApiService.baseUrl;

  /// Lista todos os eventos do banco
  Future<List<Evento>> listarEventos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/eventos'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List lista =
            jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Evento.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao listar eventos: $e');
    }
    return [];
  }

  /// Lista eventos criados pelo usuário
  Future<List<Evento>> listarEventosPorUsuario(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/eventos/usuario/$idUsuario'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List lista =
            jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Evento.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao listar eventos do usuário: $e');
    }
    return [];
  }

  /// Busca evento por ID
  Future<Evento?> buscarEventoPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/eventos/$id'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return Evento.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar evento por id: $e');
    }
    return null;
  }

  /// Cria um novo evento no backend
  Future<Evento?> criarEvento(Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/eventos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Evento.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao criar evento: $e');
    }
    return null;
  }

  /// Inscreve o usuário no evento
  Future<bool> participarEvento(int idEvento, int idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/eventos/$idEvento/participar/$idUsuario'),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Erro ao participar do evento: $e');
      return false;
    }
  }

  /// Remove a inscrição do usuário no evento
  Future<bool> sairEvento(int idEvento, int idUsuario) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/eventos/$idEvento/participar/$idUsuario'),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Erro ao sair do evento: $e');
      return false;
    }
  }

  /// Busca quantidade de participantes de um evento
  Future<int> contarParticipantes(int idEvento) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/eventos/$idEvento/participantes/quantidade'),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        return int.tryParse(response.body) ?? 0;
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao contar participantes: $e');
    }
    return 0;
  }

  /// Lista IDs de usuários participantes do evento
  Future<List<int>> listarIdsParticipantes(int idEvento) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/eventos/$idEvento/participantes'),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista
            .map<int>((item) => (item['usuarioId'] as num?)?.toInt() ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao listar participantes: $e');
    }
    return [];
  }
}
