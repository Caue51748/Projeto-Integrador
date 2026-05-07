import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {

  final UsuarioService service = UsuarioService();

  List<Usuario> usuarios = [];

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    usuarios = await service.listarUsuarios();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const UsuarioFormScreen(),
            ),
          );

          carregarUsuarios();
        },
      ),

      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {

          Usuario usuario = usuarios[index];

          return ListTile(
            title: Text(usuario.nome),
            subtitle: Text(usuario.email),
          );
        },
      ),
    );
  }
}