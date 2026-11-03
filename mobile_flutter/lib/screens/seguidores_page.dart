import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/seguimento_service.dart';
import '../services/usuario_service.dart';
import '../widgets/social_avatar.dart';
import 'public_profile_page.dart';

/// Lista real de seguidores/seguindo a partir dos IDs persistidos no backend.
class SeguidoresPage extends StatefulWidget {
  final int usuarioId;
  final bool seguidores;
  const SeguidoresPage({super.key, required this.usuarioId, required this.seguidores});

  @override
  State<SeguidoresPage> createState() => _SeguidoresPageState();
}

class _SeguidoresPageState extends State<SeguidoresPage> {
  bool _carregando = true;
  String? _erro;
  List<Usuario> _pessoas = [];

  @override
  void initState() { super.initState(); _carregar(); }

  Future<void> _carregar() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final ids = await SeguimentoService().ids(widget.usuarioId, seguidores: widget.seguidores);
      final todos = await UsuarioService().listarUsuarios();
      final pessoas = todos.where((u) => u.idUsuario != null && ids.contains(u.idUsuario)).toList();
      if (!mounted) return;
      setState(() { _pessoas = pessoas; _carregando = false; });
    } catch (e) {
      if (mounted) setState(() { _carregando = false; _erro = '$e'; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white,
      title: Text(widget.seguidores ? 'Seguidores' : 'Seguindo',
        style: const TextStyle(fontWeight: FontWeight.w800))),
    body: _carregando ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA3F74)))
      : _erro != null ? Center(child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_erro!, textAlign: TextAlign.center),
            TextButton(onPressed: _carregar, child: const Text('Tentar novamente')),
          ])))
      : _pessoas.isEmpty ? const Center(child: Text('Ainda não há pessoas nesta lista.'))
      : RefreshIndicator(onRefresh: _carregar, child: ListView.separated(
          itemCount: _pessoas.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (_, i) {
            final u = _pessoas[i];
            return ListTile(
              tileColor: Colors.white,
              leading: SocialAvatar(nome: u.nome, foto: u.fotoPerfil, radius: 23),
              title: Text(u.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('@${u.username ?? ''}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context,
                MaterialPageRoute<void>(builder: (_) => PublicProfilePage(usuarioId: u.idUsuario!))),
            );
          },
        )),
  );
}
