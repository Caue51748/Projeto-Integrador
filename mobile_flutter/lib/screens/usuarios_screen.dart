import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuarioScreen extends StatefulWidget {

  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() =>
      _UsuarioScreenState();
}

class _UsuarioScreenState
    extends State<UsuarioScreen> {

  final UsuarioService service =
      UsuarioService();

  List<Usuario> usuarios = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {

    try {

      final lista =
      await service.listarUsuarios();

      setState(() {

        usuarios = lista;
        carregando = false;
      });

    } catch (e) {

      print(e);

      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> deletarUsuario(
      int id,
      ) async {

    await service.deletarUsuario(id);

    carregarUsuarios();
  }

  Future<void> abrirFormulario(
      [Usuario? usuario]
      ) async {

    final resultado =
    await Navigator.push(

      context,

      MaterialPageRoute(
        builder: (_) =>
            UsuarioFormScreen(
              usuario: usuario,
            ),
      ),
    );

    if (resultado == true) {
      carregarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text('Usuários'),
      ),

      floatingActionButton:
      FloatingActionButton(

        onPressed: () {
          abrirFormulario();
        },

        child: const Icon(Icons.add),
      ),

      body: carregando

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : ListView.builder(

        itemCount: usuarios.length,

        itemBuilder: (context, index) {

          final usuario =
          usuarios[index];

          return Card(

            margin:
            const EdgeInsets.all(8),

            child: ListTile(

              title:
              Text(usuario.nome),

              subtitle:
              Text(usuario.email),

              trailing: Row(

                mainAxisSize:
                MainAxisSize.min,

                children: [

                  IconButton(

                    icon: const Icon(
                      Icons.edit,
                    ),

                    onPressed: () {
                      abrirFormulario(
                        usuario,
                      );
                    },
                  ),

                  IconButton(

                    icon: const Icon(
                      Icons.delete,
                    ),

                    onPressed: () {

                      deletarUsuario(
                        usuario
                            .idUsuario!,
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