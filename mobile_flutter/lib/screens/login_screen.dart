import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
  TextEditingController();

  final senhaController =
  TextEditingController();

  final UsuarioService service =
  UsuarioService();

  String erro = '';

  Future<void> login() async {

    Usuario? usuario =
    await service.login(

      emailController.text,
      senhaController.text,
    );

    if (usuario == null) {

      setState(() {

        erro =
        'Email ou senha inválidos';
      });

      return;
    }

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) =>
        const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

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

              onPressed: login,

              child: const Text('Entrar'),
            ),

            TextButton(

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const RegisterScreen(),
                  ),
                );
              },

              child: const Text(
                'Criar conta',
              ),
            ),

            const SizedBox(height: 20),

            Text(

              erro,

              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}