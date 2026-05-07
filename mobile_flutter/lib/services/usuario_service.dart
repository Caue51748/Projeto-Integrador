// lib/services/usuario_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {

  // TROQUE PELO SEU IP
  static const String baseUrl = "http://192.168.0.10:8080/usuarios";

  Future<List<Usuario>> listarUsuarios() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse
          .map((usuario) => Usuario.fromJson(usuario))
          .toList();
    } else {
      throw Exception("Erro ao listar usuários");
    }
  }

  Future<void> criarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(usuario.toJson()),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Erro ao criar usuário");
    }
  }

  Future<void> atualizarUsuario(Usuario usuario) async {

    final response = await http.put(
      Uri.parse("$baseUrl/${usuario.idUsuario}"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(usuario.toJson()),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception("Erro ao atualizar usuário");
    }
  }

  Future<void> deletarUsuario(int id) async {

    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
    );

    print(response.statusCode);

    if (response.statusCode != 200) {
      throw Exception("Erro ao deletar usuário");
    }
  }
}