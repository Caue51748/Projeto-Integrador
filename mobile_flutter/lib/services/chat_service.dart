import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

// Contrato proposto: não funcionará entre usuários até a API implementar
// GET /api/chat/mensagens?usuario1=ID&usuario2=ID e POST /api/chat/mensagens.
class MensagemChat {
  final int? id;
  final int remetenteId;
  final int destinatarioId;
  final String texto;
  final DateTime? enviadaEm;

  const MensagemChat({this.id, required this.remetenteId,
    required this.destinatarioId, required this.texto, this.enviadaEm});

  static int _num(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  factory MensagemChat.fromJson(Map<String,dynamic> json) => MensagemChat(
    id: json['id'] == null ? null : _num(json['id']),
    remetenteId: _num(json['remetenteId'] ?? json['idRemetente']),
    destinatarioId: _num(json['destinatarioId'] ?? json['idDestinatario']),
    texto: (json['texto'] ?? json['conteudo'] ?? '').toString(),
    enviadaEm: DateTime.tryParse((json['enviadaEm'] ?? json['criadaEm'] ?? '').toString()),
  );
}

class ChatService {
  Future<List<MensagemChat>> listar(int eu, int outro) async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/chat/mensagens')
        .replace(queryParameters: {'usuario1': '$eu', 'usuario2': '$outro'});
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Chat indisponível (HTTP ${response.statusCode}). Confira o endpoint no backend.');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final lista = data is List ? data : (data is Map ? data['content'] : null);
    if (lista is! List) throw const FormatException('Formato inesperado das mensagens.');
    return lista.whereType<Map>().map((m) => MensagemChat.fromJson(Map<String,dynamic>.from(m))).toList();
  }

  Future<void> enviar({required int eu, required int outro, required String texto}) async {
    final response = await http.post(Uri.parse('${ApiService.baseUrl}/api/chat/mensagens'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'remetenteId': eu, 'destinatarioId': outro, 'texto': texto}),
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Não foi possível enviar a mensagem (HTTP ${response.statusCode}).');
    }
  }
}
