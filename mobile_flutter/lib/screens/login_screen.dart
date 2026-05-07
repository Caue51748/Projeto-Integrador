import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final nomeController =
  TextEditingController();

  void entrar() {

    if (nomeController.text.isEmpty) {
      return;
    }

    AuthService.logado = true;

    AuthService.idUsuario = 1;

    AuthService.nomeUsuario =
        nomeController.text;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Login"),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              controller:
              nomeController,

              decoration:
              const InputDecoration(
                labelText: "Nome",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: entrar,

              child:
              const Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}