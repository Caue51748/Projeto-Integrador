import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../widgets/social_avatar.dart';
import 'public_profile_page.dart';

/// Lista pública de pessoas: nunca oferece exclusão/edição de outras contas.
/// Permissões verdadeiras devem ser verificadas também pelo backend.
class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});
  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final UsuarioService _service = UsuarioService();
  final TextEditingController _busca = TextEditingController();
  List<Usuario> _pessoas = [];
  String? _erro;
  bool _carregando = true;

  @override
  void initState() { super.initState(); _carregar(); }
  @override
  void dispose() { _busca.dispose(); super.dispose(); }

  Future<void> _carregar() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final pessoas = await _service.listarUsuarios();
      if (!mounted) return;
      setState(() { _pessoas = pessoas; _carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = 'Não foi possível consultar os usuários: $e'; _carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final busca = _busca.text.trim().toLowerCase();
    final exibidos = _pessoas.where((u) =>
      u.nome.toLowerCase().contains(busca) || (u.username ?? '').toLowerCase().contains(busca),
    ).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Pessoas')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Conecte-se à comunidade', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 12),
          TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por nome ou @usuário'),
          ),
          const SizedBox(height: 14),
          if (_carregando) const Center(child: CircularProgressIndicator()),
          if (_erro != null) Text(_erro!, style: const TextStyle(color: Colors.red)),
          if (!_carregando && _erro == null && exibidos.isEmpty)
            const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Nenhum usuário encontrado.'))),
          ...exibidos.map((u) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: SocialAvatar(nome: u.nome, foto: u.fotoPerfil),
              title: Text(u.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(u.username == null || u.username!.isEmpty ? 'Membro SocialJoin' : '@${u.username}'),
              onTap: () {
                if (u.idUsuario != null) {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PublicProfilePage(usuarioId: u.idUsuario!)));
                }
              },
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFEA3F74)),
            ),
          )),
        ]),
      ),
    );
  }
}
