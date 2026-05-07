// lib/screens/usuario_form_screen.dart

import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioFormScreen extends StatefulWidget {

  final Usuario? usuario;

  const UsuarioFormScreen({
    super.key,
    this.usuario,
  });

  @override
  State<UsuarioFormScreen> createState() =>
      _UsuarioFormScreenState();
}

class _UsuarioFormScreenState
    extends State<UsuarioFormScreen> {

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

      nomeController.text =
          widget.usuario!.nome;

      emailController.text =
          widget.usuario!.email;

      senhaController.text =
          widget.usuario!.senha;
    }
  }

  Future<void> salvar() async {

    Usuario usuario = Usuario(

      idUsuario:
      widget.usuario?.idUsuario,

      nome: nomeController.text,

      email: emailController.text,

      senha: senhaController.text,
    );

    if (editando) {

      await service.atualizarUsuario(usuario);

    } else {

      await service.criarUsuario(usuario);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          editando
              ? 'Editar Usuário'
              : 'Novo Usuário',
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: nomeController,

              decoration:
              const InputDecoration(
                labelText: 'Nome',
              ),
            ),

            TextField(
              controller: emailController,

              decoration:
              const InputDecoration(
                labelText: 'Email',
              ),
            ),

            TextField(
              controller: senhaController,

              decoration:
              const InputDecoration(
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