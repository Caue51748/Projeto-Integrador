import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// MensagemDTO: idMensagem, idConversa, idRemetente, nomeRemetente,
/// conteudo, dataEnvio, lida. Conserva o modelo usado pela UI atual.
class MensagemChat {
  final int? id;
  final int remetenteId;
  final int destinatarioId;
  final String texto;
  final DateTime? enviadaEm;

  const MensagemChat({this.id, required this.remetenteId,
    required this.destinatarioId, required this.texto, this.enviadaEm});

  static int _numero(dynamic valor) => valor is num
      ? valor.toInt() : int.tryParse('$valor') ?? 0;

  factory MensagemChat.fromJson(Map<String, dynamic> json) => MensagemChat(
    id: json['idMensagem'] == null ? null : _numero(json['idMensagem']),
    remetenteId: _numero(json['idRemetente']),
    destinatarioId: 0, // o destinatário não é exposto em MensagemDTO
    texto: (json['conteudo'] ?? '').toString(),
    enviadaEm: DateTime.tryParse((json['dataEnvio'] ?? '').toString()),
  );
}

class ChatService {
  final Map<String, int> _conversas = <String, int>{};
  String get _base => ApiService.baseUrl;
  String _chave(int a, int b) =>
      a < b ? '$a:$b' : '$b:$a';

  Future<int> _buscarOuCriarConversa(int eu, int outro) async {
    if (eu == outro) throw ArgumentError('Não é possível conversar consigo mesmo.');
    final chave = _chave(eu, outro);
    final idExistente = _conversas[chave];
    if (idExistente != null) return idExistente;

    // ConversaController @PostMapping em /conversas.
    final res = await http.post(Uri.parse('$_base/conversas'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'idUsuario': eu, 'idOutroUsuario': outro}),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Não foi possível abrir conversa (HTTP ${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is! Map || data['idConversa'] == null) {
      throw const FormatException('O Java não devolveu idConversa.');
    }
    final id = data['idConversa'] is num
        ? (data['idConversa'] as num).toInt()
        : int.tryParse('${data['idConversa']}');
    if (id == null || id <= 0) {
      throw const FormatException('idConversa inválido.');
    }
    _conversas[chave] = id;
    return id;
  }

  Future<List<MensagemChat>> listar(int eu, int outro) async {
    final id = await _buscarOuCriarConversa(eu, outro);
    // MensagemController @GetMapping('/conversa/{idConversa}')
    final res = await http.get(Uri.parse('$_base/mensagens/conversa/$id'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Falha ao buscar mensagens (HTTP ${res.statusCode}): ${res.body}');
    }
    final dados = jsonDecode(utf8.decode(res.bodyBytes));
    if (dados is! List) throw const FormatException('Resposta de mensagens inválida.');
    return dados.whereType<Map>()
        .map((m) => MensagemChat.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> enviar({required int eu, required int outro,
      required String texto}) async {
    if (texto.trim().isEmpty) return;
    final idConversa = await _buscarOuCriarConversa(eu, outro);
    // MensagemController @PostMapping('/mensagens')
    final res = await http.post(Uri.parse('$_base/mensagens'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'idConversa': idConversa,
        'idRemetente': eu,
        'conteudo': texto.trim(),
      }),
    ).timeout(const Duration(seconds: 15));
    if (kDebugMode) debugPrint('CHAT SEND: HTTP ${res.statusCode}: ${res.body}');
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Não foi possível enviar mensagem (HTTP ${res.statusCode}): ${res.body}');
    }
  }
}
