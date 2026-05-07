import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final nomeController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final senhaController =
  TextEditingController();

  final UsuarioService service =
  UsuarioService();

  String mensagem = '';

  Future<void> cadastrar() async {

    Usuario usuario = Usuario(

      nome: nomeController.text,

      email: emailController.text,

      senha: senhaController.text,
    );

    await service.criarUsuario(
      usuario,
    );

    setState(() {

      mensagem =
      'Usuário cadastrado!';
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Cadastro'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

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

              obscureText: true,

              decoration:
              const InputDecoration(
                labelText: 'Senha',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: cadastrar,

              child: const Text(
                'Cadastrar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}