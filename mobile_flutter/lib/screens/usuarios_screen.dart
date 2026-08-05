import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final UsuarioService service = UsuarioService();
  final TextEditingController searchController = TextEditingController();

  List<Usuario> usuarios = [];
  List<Usuario> usuariosFiltrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    try {
      final lista = await service.listarUsuarios();
      setState(() {
        usuarios = lista;
        usuariosFiltrados = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });
    }
  }

  void _filtrar(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        usuariosFiltrados = usuarios;
      } else {
        usuariosFiltrados = usuarios.where((u) {
          return u.nome.toLowerCase().contains(query.toLowerCase()) ||
              u.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> deletarUsuario(int id) async {
    await service.deletarUsuario(id);
    carregarUsuarios();
  }

  Future<void> abrirFormulario([Usuario? usuario]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsuarioFormScreen(
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
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(),
        backgroundColor: const Color(0xFFEA3F74),
        elevation: 4,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Novo Usuário", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: _filtrar,
              decoration: InputDecoration(
                hintText: "Buscar usuário por nome ou email...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA3F74)))
                  : usuariosFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum usuário encontrado.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          itemCount: usuariosFiltrados.length,
                          itemBuilder: (context, index) {
                            final usuario = usuariosFiltrados[index];
                            final inicial = usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFFDF0F4),
                                  child: Text(
                                    inicial,
                                    style: const TextStyle(color: Color(0xFFEA3F74), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  usuario.nome,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                subtitle: Text(
                                  usuario.email,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Color(0xFFEA3F74), size: 20),
                                      onPressed: () => abrirFormulario(usuario),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                      onPressed: () {
                                        if (usuario.idUsuario != null) {
                                          deletarUsuario(usuario.idUsuario!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}