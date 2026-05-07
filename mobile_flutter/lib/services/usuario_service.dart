import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {

  Future<List<Usuario>> listarUsuarios() async {
    final response = await http.get(Uri.parse(ApiService.usuarios));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((u) => Usuario.fromJson(u)).toList();
    } else {
      throw Exception('Erro ao carregar usuários');
    }
  }

  Future<void> criarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(ApiService.usuarios),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Erro ao criar usuário');
    }
  }
}