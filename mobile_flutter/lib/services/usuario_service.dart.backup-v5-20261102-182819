import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {
  String get baseUrl => ApiService.baseUrl;

  Future<Usuario?> login(String email, String senha) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'senha': senha}),
      ).timeout(const Duration(seconds: 15));
      if (kDebugMode) debugPrint('LOGIN HTTP ${res.statusCode}: ${_resumo(res.body)}');
      if (res.statusCode != 200 || res.body.trim().isEmpty || res.body.trim() == 'null') {
        return null;
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is! Map) return null;
      final usuario = Usuario.fromJson(Map<String, dynamic>.from(data));
      if (usuario.email.isEmpty) usuario.email = email;
      return usuario;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro no login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> criarUsuario({
    required String nome,
    required String username,
    required String email,
    required String senha,
    String? dataNascimento,
    String? nomeCompleto,
  }) async {
    try {
      final payload = {
        'nome': nome,
        'nomeCompleto': nomeCompleto?.isNotEmpty == true ? nomeCompleto : nome,
        'username': username,
        'email': email,
        'senha': senha,
        'dataNascimento': dataNascimento?.isNotEmpty == true ? dataNascimento : '2000-01-01',
      };
      final response = await http.post(Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 18));
      if (kDebugMode) debugPrint('CADASTRO HTTP ${response.statusCode}: ${_resumo(response.body)}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty) {
          return {'sucesso': false, 'erro': 'Conta criada, mas a API não retornou os dados. Faça login.'};
        }
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {'sucesso': true, 'usuario': Usuario.fromJson(Map<String, dynamic>.from(data))};
      }
      return {'sucesso': false, 'erro': 'Não foi possível concluir o cadastro (HTTP ${response.statusCode}). ${_resumo(response.body)}'};
    } catch (e) {
      if (kDebugMode) debugPrint('CADASTRO ERRO: $e');
      return {'sucesso': false, 'erro': 'Não foi possível conectar ao servidor: $e'};
    }
  }

  Future<Usuario?> buscarPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios/$id'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) return null;
      return Usuario.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) debugPrint('Buscar usuário: $e');
      return null;
    }
  }

  Future<bool> atualizarPerfil(int id, String nome, String bio) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/usuarios/$id/perfil'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nome, 'bio': bio}),
      ).timeout(const Duration(seconds: 12));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) debugPrint('Atualizar perfil: $e');
      return false;
    }
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = data is List ? data : (data is Map ? data['content'] : null);
      if (lista is! List) return [];
      return lista.whereType<Map>().map((e) => Usuario.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Listar usuários: $e');
      return [];
    }
  }

  // Mantém assinatura antiga; não deve estar exposto a usuários comuns na UI.
  Future<void> deletarUsuario(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/usuarios/$id'))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Exclusão recusada (HTTP ${response.statusCode}).');
    }
  }

  static const String _perfilPath = String.fromEnvironment(
    'PROFILE_IMAGE_UPLOAD_PATH', defaultValue: '/usuarios/{id}/foto');
  static const String _perfilField = String.fromEnvironment(
    'PROFILE_IMAGE_FIELD', defaultValue: 'foto');

  Future<Map<String, dynamic>> atualizarFotoPerfil({
    required int idUsuario,
    String? caminhoArquivo,
    Uint8List? bytes,
    required String nomeArquivo,
  }) async {
    try {
      if (bytes == null && caminhoArquivo == null) {
        return {'sucesso': false, 'erro': 'Selecione uma imagem.'};
      }
      if (bytes != null && bytes.length > 5 * 1024 * 1024) {
        return {'sucesso': false, 'erro': 'A foto deve ter até 5 MB.'};
      }
      final caminho = _perfilPath.replaceAll('{id}', '$idUsuario');
      final uri = Uri.parse('$baseUrl$caminho');
      final request = http.MultipartRequest('POST', uri);
      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(_perfilField, bytes,
          filename: nomeArquivo));
      } else {
        request.files.add(await http.MultipartFile.fromPath(_perfilField,
          caminhoArquivo!, filename: nomeArquivo));
      }
      final stream = await request.send().timeout(const Duration(seconds: 35));
      final response = await http.Response.fromStream(stream);
      if (kDebugMode) {
        debugPrint('UPLOAD PERFIL $uri, campo $_perfilField: HTTP ${response.statusCode}; ${_resumo(response.body)}');
      }
      if (![200, 201, 204].contains(response.statusCode)) {
        return {'sucesso': false,
          'erro': 'Servidor recusou a foto (HTTP ${response.statusCode}). '
            'Resposta: ${_resumo(response.body)}'};
      }
      Usuario? atualizado;
      if (response.body.trim().isNotEmpty) {
        try {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          if (body is Map) atualizado = Usuario.fromJson(Map<String, dynamic>.from(body));
        } catch (_) {}
      }
      // O Web usa o mesmo perfil do Java; buscar novamente garante o
      // caminho salvo quando o POST retorna somente uma mensagem.
      final servidor = await buscarPorId(idUsuario);
      if (servidor?.fotoPerfil != null && servidor!.fotoPerfil!.trim().isNotEmpty) {
        atualizado = servidor;
      }
      if (atualizado?.fotoPerfil == null || atualizado!.fotoPerfil!.trim().isEmpty) {
        return {'sucesso': false,
          'erro': 'Upload aceito, mas a API não devolveu uma fotoPerfil válida. '
            'Verifique o armazenamento e o retorno de GET /usuarios/$idUsuario.'};
      }
      return {'sucesso': true, 'usuario': atualizado};
    } catch (e) {
      if (kDebugMode) debugPrint('UPLOAD FOTO ERRO: $e');
      return {'sucesso': false, 'erro': 'Erro ao enviar a foto: $e'};
    }
  }

  static String _resumo(String msg) =>
      msg.length > 250 ? '${msg.substring(0, 250)}...' : msg;
}
