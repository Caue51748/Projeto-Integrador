// lib/screens/usuario_form_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormScreen({
    super.key,
    this.usuario,
  });

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final UsuarioService service = UsuarioService();

  bool editando = false;

  @override
  void initState() {
    super.initState();

    if (widget.usuario != null) {
      editando = true;
      nomeController.text = widget.usuario!.nome;
      emailController.text = widget.usuario!.email;
      senhaController.text = widget.usuario!.senha;
    }
  }

  Future<void> salvar() async {
    if (editando && widget.usuario?.idUsuario != null) {
      // Atualiza perfil do usuário
      await http.put(
        Uri.parse('http://localhost:8080/usuarios/${widget.usuario!.idUsuario}/perfil'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nomeController.text}),
      );
    } else {
      // Cria novo usuário usando a assinatura correta
      await service.criarUsuario(
        nome: nomeController.text,
        username: emailController.text.split('@')[0],
        email: emailController.text,
        senha: senhaController.text,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editando ? 'Editar Usuário' : 'Novo Usuário',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvar,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
