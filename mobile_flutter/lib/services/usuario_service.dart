import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class UsuarioService {

  static const String baseUrl =
      'http://192.168.1.218:8080';

  Future<Usuario?> login(
      String email,
      String senha,
      ) async {

    final response = await http.post(

      Uri.parse('$baseUrl/auth/login'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({

        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200 &&
        response.body != 'null') {

      return Usuario.fromJson(
        jsonDecode(response.body),
      );
    }

    return null;
  }

  Future<List<Usuario>> listarUsuarios() async {

    final response = await http.get(
      Uri.parse('$baseUrl/usuarios'),
    );

    final List lista =
    jsonDecode(response.body);

    return lista
        .map((e) => Usuario.fromJson(e))
        .toList();
  }

  Future<void> criarUsuario(
      Usuario usuario,
      ) async {

    await http.post(

      Uri.parse('$baseUrl/usuarios'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode(
        usuario.toJson(),
      ),
    );
  }

  Future<void> atualizarUsuario(
      int id,
      Usuario usuario,
      ) async {

    await http.put(

      Uri.parse('$baseUrl/usuarios/$id'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode(
        usuario.toJson(),
      ),
    );
  }

  Future<void> deletarUsuario(
      int id,
      ) async {

    await http.delete(
      Uri.parse('$baseUrl/usuarios/$id'),
    );
  }
}