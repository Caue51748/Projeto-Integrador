// lib/screens/usuarios_screen.dart

import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() =>
      _UsuariosScreenState();
}

class _UsuariosScreenState
    extends State<UsuariosScreen> {

  final UsuarioService service = UsuarioService();

  List<Usuario> usuarios = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {

    usuarios = await service.listarUsuarios();

    setState(() {
      carregando = false;
    });
  }

  Future<void> deletar(int id) async {

    await service.deletarUsuario(id);

    carregarUsuarios();
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
              builder: (_) =>
              const UsuarioFormScreen(),
            ),
          );

          carregarUsuarios();
        },
      ),

      body: carregando
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : ListView.builder(

        itemCount: usuarios.length,

        itemBuilder: (context, index) {

          Usuario usuario = usuarios[index];

          return Card(

            child: ListTile(

              title: Text(usuario.nome),

              subtitle: Text(usuario.email),

              trailing: Row(

                mainAxisSize: MainAxisSize.min,

                children: [

                  IconButton(

                    icon: const Icon(Icons.edit),

                    onPressed: () async {

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UsuarioFormScreen(
                                usuario: usuario,
                              ),
                        ),
                      );

                      carregarUsuarios();
                    },
                  ),

                  IconButton(

                    icon: const Icon(Icons.delete),

                    onPressed: () {
                      deletar(
                        usuario.idUsuario!,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}