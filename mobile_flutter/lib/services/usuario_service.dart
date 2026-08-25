import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {
  String get baseUrl => ApiService.baseUrl;

  /// Login via POST /usuarios/login — retorna UsuarioPerfilDTO
  Future<Usuario?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('=== LOGIN RESPONSE ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200 &&
          response.body.isNotEmpty &&
          response.body != 'null') {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final user = Usuario.fromJson(json);
        user.email = email; // Garante que o email esteja presente
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Erro no login: $e');
      return null;
    }
  }

  /// Cadastro via POST /usuarios — envia nome, username, email, senha
  Future<Map<String, dynamic>> criarUsuario({
    required String nome,
    required String username,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'username': username,
          'email': email,
          'senha': senha,
        }),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('=== CADASTRO RESPONSE ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return {'sucesso': true, 'usuario': Usuario.fromJson(json)};
      }

      String mensagemErro = 'Erro ao criar conta. Tente novamente.';
      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('username') || bodyLower.contains('unique index') && bodyLower.contains('user')) {
        mensagemErro = 'Este nome de usuário já está em uso.';
      } else if (bodyLower.contains('email')) {
        mensagemErro = 'Este e-mail já está cadastrado.';
      }
      return {'sucesso': false, 'erro': mensagemErro};
    } catch (e) {
      if (kDebugMode) print('Erro no cadastro: $e');
      return {'sucesso': false, 'erro': 'Sem conexão com o servidor.'};
    }
  }

  /// Busca perfil completo do usuário por ID
  Future<Usuario?> buscarPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return Usuario.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  /// Atualiza nome e bio do perfil via PUT /usuarios/{id}/perfil
  Future<bool> atualizarPerfil(int id, String nome, String bio) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id/perfil'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nome, 'bio': bio}),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Usuario.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao listar usuários: $e');
    }
    return [];
  }

  Future<void> deletarUsuario(int id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/usuarios/$id'));
    } catch (e) {
      if (kDebugMode) print('Erro ao deletar usuário: $e');
    }
  }
}