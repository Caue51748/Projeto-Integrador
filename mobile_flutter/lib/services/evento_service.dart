import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/evento.dart';
import 'api_service.dart';

class EventoService {
  String get baseUrl => ApiService.baseUrl;

  /// Lista todos os eventos do banco.
  /// Aceita tanto resposta em formato List [...]
  /// quanto Page { "content": [...] }.
  Future<List<Evento>> listarEventos() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/eventos'),
          )
          .timeout(const Duration(seconds: 8));

      if (kDebugMode) {
        print('EVENTOS STATUS: ${response.statusCode}');
        print('EVENTOS BODY: ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> listaData = [];

        if (decoded is List) {
          listaData = decoded;
        } else if (decoded is Map &&
            decoded['content'] is List) {
          listaData = decoded['content'];
        }

        return listaData
            .whereType<Map<String, dynamic>>()
            .map((e) => Evento.fromJson(e))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERRO LISTAR EVENTOS: $e');
      }
    }

    return [];
  }

  /// Lista eventos criados pelo usuário.
  Future<List<Evento>> listarEventosPorUsuario(
    int idUsuario,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/eventos/usuario/$idUsuario',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> listaData = [];

        if (decoded is List) {
          listaData = decoded;
        } else if (decoded is Map &&
            decoded['content'] is List) {
          listaData = decoded['content'];
        }

        return listaData
            .whereType<Map<String, dynamic>>()
            .map((e) => Evento.fromJson(e))
            .toList();
      }

      if (kDebugMode) {
        print(
          'Erro HTTP ao listar eventos do usuário: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao listar eventos do usuário: $e',
        );
      }
    }

    return [];
  }

  /// Busca um evento pelo ID.
  Future<Evento?> buscarEventoPorId(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/eventos/$id',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          return Evento.fromJson(decoded);
        }

        if (decoded is Map) {
          return Evento.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }

      if (kDebugMode) {
        print(
          'Erro HTTP ao buscar evento por ID: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao buscar evento por ID: $e',
        );
      }
    }

    return null;
  }

  /// Cria um novo evento no backend.
  Future<Evento?> criarEvento(
    Map<String, dynamic> dados,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/api/eventos',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(dados),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          return Evento.fromJson(decoded);
        }

        if (decoded is Map) {
          return Evento.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      }

      if (kDebugMode) {
        print(
          'Erro HTTP ao criar evento: '
          '${response.statusCode}',
        );
        print(
          'Resposta: '
          '${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao criar evento: $e',
        );
      }
    }

    return null;
  }

  /// Inscreve o usuário em um evento.
  Future<bool> participarEvento(
    int idEvento,
    int idUsuario,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/api/eventos/'
              '$idEvento/participar/$idUsuario',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (kDebugMode) {
        print(
          'PARTICIPAR EVENTO STATUS: '
          '${response.statusCode}',
        );
      }

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao participar do evento: $e',
        );
      }

      return false;
    }
  }

  /// Remove a inscrição do usuário em um evento.
  Future<bool> sairEvento(
    int idEvento,
    int idUsuario,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              '$baseUrl/api/eventos/'
              '$idEvento/participar/$idUsuario',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (kDebugMode) {
        print(
          'SAIR EVENTO STATUS: '
          '${response.statusCode}',
        );
      }

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao sair do evento: $e',
        );
      }

      return false;
    }
  }

  /// Busca a quantidade de participantes de um evento.
  Future<int> contarParticipantes(
    int idEvento,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/eventos/'
              '$idEvento/participantes/quantidade',
            ),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body =
            utf8.decode(response.bodyBytes).trim();

        final numeroDireto =
            int.tryParse(body);

        if (numeroDireto != null) {
          return numeroDireto;
        }

        try {
          final decoded = jsonDecode(body);

          if (decoded is int) {
            return decoded;
          }

          if (decoded is num) {
            return decoded.toInt();
          }

          if (decoded is Map) {
            final valor =
                decoded['quantidade'] ??
                decoded['total'] ??
                decoded['count'];

            if (valor is num) {
              return valor.toInt();
            }

            return int.tryParse(
                  valor?.toString() ?? '',
                ) ??
                0;
          }
        } catch (_) {}
      }

      if (kDebugMode) {
        print(
          'Erro HTTP ao contar participantes: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao contar participantes: $e',
        );
      }
    }

    return 0;
  }

  /// Lista os IDs dos usuários participantes do evento.
  Future<List<int>> listarIdsParticipantes(
    int idEvento,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/eventos/'
              '$idEvento/participantes',
            ),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded is List) {
          final ids = <int>[];

          for (final item in decoded) {
            if (item is int) {
              ids.add(item);
              continue;
            }

            if (item is num) {
              ids.add(item.toInt());
              continue;
            }

            if (item is Map) {
              final valor =
                  item['usuarioId'] ??
                  item['idUsuario'] ??
                  item['id_usuario'] ??
                  item['id'];

              if (valor is num) {
                ids.add(valor.toInt());
              } else {
                final id =
                    int.tryParse(
                      valor?.toString() ?? '',
                    );

                if (id != null) {
                  ids.add(id);
                }
              }
            }
          }

          return ids
              .where((id) => id > 0)
              .toList();
        }
      }

      if (kDebugMode) {
        print(
          'Erro HTTP ao listar participantes: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Erro ao listar participantes: $e',
        );
      }
    }

    return [];
  }
}