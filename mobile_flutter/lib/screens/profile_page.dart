import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final UsuarioService _service = UsuarioService();
  Usuario? _usuario;
  bool _carregando = true;
  String? _erro;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarPerfil();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      setState(() {
        _erro = 'Faça login para ver seu perfil.';
        _carregando = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    final usuario = await _service.buscarPorId(AuthService.idUsuario!);
    if (mounted) {
      setState(() {
        _usuario = usuario;
        _carregando = false;
        if (usuario == null) {
          _erro = 'Não foi possível carregar o perfil.';
        }
      });
    }
  }

  void _abrirEditar() {
    if (_usuario == null) return;

    final nomeCtrl = TextEditingController(text: _usuario!.nome);
    final bioCtrl = TextEditingController(text: _usuario!.bio ?? '');
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.edit_rounded,
                      color: Color(0xFFEA3F74), size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Editar Perfil',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo Nome
              TextField(
                controller: nomeCtrl,
                decoration: _inputDecoration(
                    'Nome Completo', Icons.person_outline_rounded),
              ),
              const SizedBox(height: 14),

              // Campo Bio
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: _inputDecoration(
                    'Biografia (opcional)', Icons.info_outline_rounded),
              ),
              const SizedBox(height: 6),

              Text(
                'Seu username @${_usuario!.username ?? ''} não pode ser alterado.',
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA3F74),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: salvando
                    ? null
                    : () async {
                        if (nomeCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('O nome não pode ser vazio.'),
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                          return;
                        }

                        setModal(() => salvando = true);

                        // Captura messenger e navigator antes do await
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(ctx);

                        final ok = await _service.atualizarPerfil(
                          AuthService.idUsuario!,
                          nomeCtrl.text.trim(),
                          bioCtrl.text.trim(),
                        );

                        if (!mounted) return;
                        nav.pop();

                        if (ok) {
                          AuthService.nomeUsuario = nomeCtrl.text.trim();
                          AuthService.bio = bioCtrl.text.trim();

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Perfil atualizado com sucesso!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );

                          _carregarPerfil();
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao salvar. Tente novamente.'),
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                        }
                      },
                child: salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Salvar Alterações',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEA3F74)))
          : _erro != null
              ? _buildErro()
              : _buildPerfil(),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_rounded,
                size: 60, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            if (AuthService.logado)
              ElevatedButton.icon(
                onPressed: _carregarPerfil,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA3F74),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfil() {
    final usuario = _usuario!;
    final inicial = usuario.nome.isNotEmpty
        ? usuario.nome[0].toUpperCase()
        : 'U';

    return RefreshIndicator(
      onRefresh: _carregarPerfil,
      color: const Color(0xFFEA3F74),
      child: CustomScrollView(
        slivers: [
          // Header com gradiente
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEA3F74), Color(0xFFFF6B9D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      // Avatar e botão editar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                inicial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          // Botão editar
                          GestureDetector(
                            onTap: _abrirEditar,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Editar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Nome e username
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (usuario.username != null &&
                                usuario.username!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '@${usuario.username}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                            if (usuario.bio != null &&
                                usuario.bio!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                usuario.bio!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Informações do perfil
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de informações
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFFEEF2F7))),
                    ),
                    child: Column(
                      children: [
                        _infoItem(
                          Icons.person_outline_rounded,
                          'Nome',
                          usuario.nome,
                        ),
                        _divider(),
                        _infoItem(
                          Icons.alternate_email_rounded,
                          'Username',
                          usuario.username != null
                              ? '@${usuario.username}'
                              : 'Não definido',
                        ),
                        _divider(),
                        _infoItem(
                          Icons.email_outlined,
                          'E-mail',
                          usuario.email,
                        ),
                        if (usuario.bio != null &&
                            usuario.bio!.isNotEmpty) ...[
                          _divider(),
                          _infoItem(
                            Icons.info_outline_rounded,
                            'Bio',
                            usuario.bio!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botão de logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            title: const Text('Sair da conta',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18)),
                            content: const Text(
                                'Tem certeza que deseja sair?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar',
                                    style: TextStyle(
                                        color: Color(0xFF64748B))),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFEA3F74),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  AuthService.fazerLogout();
                                  setState(() {});
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Você saiu da conta.'),
                                    ),
                                  );
                                },
                                child: const Text('Sair'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sair da conta',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFEA3F74)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
        height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 16);
  }
}
