import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static const String baseUrl = 'http://localhost:8080';

  /// Login via POST /usuarios/login — retorna UsuarioPerfilDTO
  Future<Usuario?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      print('=== LOGIN RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 &&
          response.body.isNotEmpty &&
          response.body != 'null') {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return Usuario.fromJson(json);
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
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
      );

      print('=== CADASTRO RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return {'sucesso': true, 'usuario': Usuario.fromJson(json)};
      }

      String mensagemErro = 'Erro ao criar conta. Tente novamente.';
      if (response.body.toLowerCase().contains('username')) {
        mensagemErro = 'Este nome de usuário já está em uso.';
      } else if (response.body.toLowerCase().contains('email')) {
        mensagemErro = 'Este e-mail já está cadastrado.';
      }
      return {'sucesso': false, 'erro': mensagemErro};
    } catch (e) {
      print('Erro no cadastro: $e');
      return {'sucesso': false, 'erro': 'Sem conexão com o servidor.'};
    }
  }

  /// Busca perfil completo do usuário por ID
  Future<Usuario?> buscarPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios/$id'));
      if (response.statusCode == 200) {
        return Usuario.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
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
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios'));
      if (response.statusCode == 200) {
        final List lista = jsonDecode(utf8.decode(response.bodyBytes));
        return lista.map((e) => Usuario.fromJson(e)).toList();
      }
    } catch (e) {
      print('Erro ao listar usuários: $e');
    }
    return [];
  }

  Future<void> deletarUsuario(int id) async {
    await http.delete(Uri.parse('$baseUrl/usuarios/$id'));
  }
}