import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/usuario.dart';
import '../widgets/social_avatar.dart';

/// Configurações reais de conta. Ações que alteram o perfil são delegadas à tela original.
class ConfiguracoesSocialPage extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onEditar;
  final VoidCallback onAlterarFoto;
  final VoidCallback onSair;
  const ConfiguracoesSocialPage({super.key, required this.usuario,
    required this.onEditar, required this.onAlterarFoto, required this.onSair});

  @override
  Widget build(BuildContext context) {
    const rosa = Color(0xFFEA3F74);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Configurações', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 20, 18, 36), children: [
        Container(padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            SocialAvatar(nome: usuario.nome, foto: usuario.fotoPerfil, radius: 29),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(usuario.nome, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 3),
              Text('@${usuario.username ?? ''}', style: const TextStyle(color: Color(0xFF7B8292))),
            ])),
          ])),
        const SizedBox(height: 24),
        const Text('CONTA', style: TextStyle(fontSize: 11, letterSpacing: 1.3,
          color: Color(0xFF838798), fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _opcao(Icons.manage_accounts_outlined, 'Editar perfil', 'Nome, usuário e biografia', onEditar),
        _opcao(Icons.photo_camera_outlined, 'Foto de perfil', 'Trocar sua foto', onAlterarFoto),
        _opcao(Icons.alternate_email_rounded, 'Copiar meu @', '@${usuario.username ?? ''}', () async {
          await Clipboard.setData(ClipboardData(text: '@${usuario.username ?? ''}'));
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nome de usuário copiado.')));
        }),
        const SizedBox(height: 24),
        const Text('APLICATIVO', style: TextStyle(fontSize: 11, letterSpacing: 1.3,
          color: Color(0xFF838798), fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _opcao(Icons.info_outline_rounded, 'Sobre o SocialJoin',
          'Rede social de comunidades e eventos', () {
            showAboutDialog(context: context, applicationName: 'SocialJoin',
              applicationVersion: 'TCC', applicationLegalese: 'Projeto Integrador');
          }),
        const SizedBox(height: 20),
        OutlinedButton.icon(onPressed: () => _confirmarSaida(context, onSair),
          icon: const Icon(Icons.logout_rounded), label: const Text('Sair da conta'),
          style: OutlinedButton.styleFrom(foregroundColor: rosa,
            padding: const EdgeInsets.symmetric(vertical: 14))),
      ]),
    );
  }

  Widget _opcao(IconData icone, String titulo, String detalhe, VoidCallback onTap) =>
    Padding(padding: const EdgeInsets.only(bottom: 7), child: Material(color: Colors.white,
      borderRadius: BorderRadius.circular(14), child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        leading: Icon(icone, color: const Color(0xFFEA3F74), size: 23),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(detalhe, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA0AD)),
        onTap: onTap,
      )));

  void _confirmarSaida(BuildContext context, VoidCallback sair) {
    showDialog<void>(context: context, builder: (_) => AlertDialog(
      title: const Text('Sair da conta?'),
      content: const Text('Você poderá entrar novamente quando quiser.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { Navigator.pop(context); sair(); }, child: const Text('Sair')),
      ],
    ));
  }
}
