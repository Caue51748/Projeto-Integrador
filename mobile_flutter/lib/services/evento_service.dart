import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/evento.dart';

class EventoService {
  static const String baseUrl = 'http://localhost:8080';

  /// Lista todos os eventos do banco
  Future<List<Evento>> listarEventos() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/eventos'));
      if (response.statusCode == 200) {
        final List lista =
            jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Evento.fromJson(e)).toList();
      }
    } catch (e) {
      print('Erro ao listar eventos: $e');
    }
    return [];
  }

  /// Cria um novo evento no backend
  Future<Evento?> criarEvento(Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/eventos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Evento.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      print('Erro ao criar evento: $e');
    }
    return null;
  }

  /// Inscreve o usuário no evento
  Future<bool> participarEvento(int idEvento, int idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/eventos/$idEvento/participar/$idUsuario'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erro ao participar do evento: $e');
      return false;
    }
  }

  /// Remove a inscrição do usuário no evento
  Future<bool> sairEvento(int idEvento, int idUsuario) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/eventos/$idEvento/participar/$idUsuario'),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Erro ao sair do evento: $e');
      return false;
    }
  }

  /// Busca quantidade de participantes de um evento
  Future<int> contarParticipantes(int idEvento) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/eventos/$idEvento/participantes/quantidade'),
      );
      if (response.statusCode == 200) {
        return int.tryParse(response.body) ?? 0;
      }
    } catch (e) {
      print('Erro ao contar participantes: $e');
    }
    return 0;
  }
}
