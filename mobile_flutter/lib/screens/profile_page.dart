import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/post.dart';
import '../models/evento.dart';
import '../models/comunidade.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../services/post_service.dart';
import '../services/evento_service.dart';
import '../services/comunidade_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final UsuarioService _usuarioService = UsuarioService();
  final PostService _postService = PostService();
  final EventoService _eventoService = EventoService();
  final ComunidadeService _comunidadeService = ComunidadeService();

  Usuario? _usuario;
  List<Post> _userPosts = [];
  List<Evento> _userEventos = [];
  List<Comunidade> _userComunidades = [];

  bool _carregando = true;
  String? _erro;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarDadosCompletos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosCompletos() async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      setState(() {
        _erro = 'Faça login para ver seu perfil.';
        _carregando = false;
      });
      return;
    }

    final id = AuthService.idUsuario!;
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final userFuture = _usuarioService.buscarPorId(id);
      final postsFuture = _postService.listarPostsPorUsuario(id);
      final eventosFuture = _eventoService.listarEventosPorUsuario(id);
      final comunidadesFuture = _comunidadeService.listarComunidadesPorUsuario(id);

      final results = await Future.wait([
        userFuture,
        postsFuture,
        eventosFuture,
        comunidadesFuture,
      ]);

      if (mounted) {
        setState(() {
          _usuario = results[0] as Usuario?;
          _userPosts = results[1] as List<Post>;
          _userEventos = results[2] as List<Evento>;
          _userComunidades = results[3] as List<Comunidade>;
          _carregando = false;

          if (_usuario == null) {
            // Se backend retornar vazio, usa os dados em memória do AuthService
            _usuario = Usuario(
              idUsuario: AuthService.idUsuario,
              nome: AuthService.nomeUsuario ?? 'Usuário',
              email: AuthService.emailUsuario ?? '',
              senha: '',
              username: AuthService.username,
              bio: AuthService.bio,
            );
          } else {
            // Atualiza sessão local
            if (_usuario!.nome.isNotEmpty) AuthService.nomeUsuario = _usuario!.nome;
            if (_usuario!.username != null) AuthService.username = _usuario!.username;
            if (_usuario!.bio != null) AuthService.bio = _usuario!.bio;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar as informações do perfil.';
          _carregando = false;
        });
      }
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

              const Row(
                children: [
                  Icon(Icons.edit_rounded, color: Color(0xFFEA3F74), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
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

                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(ctx);

                        final ok = await _usuarioService.atualizarPerfil(
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

                          _carregarDadosCompletos();
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
                    : const Text(
                        'Salvar Alterações',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
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
                onPressed: _carregarDadosCompletos,
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
      onRefresh: _carregarDadosCompletos,
      color: const Color(0xFFEA3F74),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Header Hero com gradiente
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // Avatar e botão editar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 68,
                            height: 68,
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
                                  fontSize: 28,
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
                      const SizedBox(height: 12),

                      // Nome, username e bio
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                            if (usuario.bio != null &&
                                usuario.bio!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                usuario.bio!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Contador de Estatísticas (Posts, Eventos, Comunidades)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Posts', _userPosts.length.toString()),
                            _buildVerticalDivider(),
                            _buildStatItem(
                                'Eventos', _userEventos.length.toString()),
                            _buildVerticalDivider(),
                            _buildStatItem('Grupos',
                                _userComunidades.length.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TabBar fixa
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFEA3F74),
                indicatorWeight: 3,
                labelColor: const Color(0xFFEA3F74),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Sobre'),
                  Tab(text: 'Posts'),
                  Tab(text: 'Eventos'),
                  Tab(text: 'Grupos'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabSobre(usuario),
            _buildTabPosts(),
            _buildTabEventos(),
            _buildTabComunidades(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildTabSobre(Usuario usuario) {
    final emailExibicao = (usuario.email.isNotEmpty)
        ? usuario.email
        : (AuthService.emailUsuario ?? 'Não informado');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEEF2F7)),
            ),
            child: Column(
              children: [
                _infoItem(
                  Icons.person_outline_rounded,
                  'Nome Completo',
                  usuario.nome,
                ),
                _divider(),
                _infoItem(
                  Icons.alternate_email_rounded,
                  'Nome de Usuário',
                  usuario.username != null
                      ? '@${usuario.username}'
                      : 'Não definido',
                ),
                _divider(),
                _infoItem(
                  Icons.email_outlined,
                  'E-mail',
                  emailExibicao,
                ),
                if (usuario.bio != null && usuario.bio!.isNotEmpty) ...[
                  _divider(),
                  _infoItem(
                    Icons.info_outline_rounded,
                    'Biografia',
                    usuario.bio!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botão de Logout
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
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    content: const Text('Tem certeza que deseja sair?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Color(0xFF64748B))),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA3F74),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          AuthService.fazerLogout();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Você saiu da conta.'),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTabPosts() {
    if (_userPosts.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.article_outlined,
        title: 'Nenhuma publicação',
        subtitle: 'Você ainda não compartilhou nenhum post.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final p = _userPosts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEEF2F7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.conteudo,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabEventos() {
    if (_userEventos.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.event_busy_rounded,
        title: 'Nenhum evento criado',
        subtitle: 'Você ainda não organizou nenhum evento.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userEventos.length,
      itemBuilder: (context, index) {
        final e = _userEventos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEEF2F7)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event, color: Color(0xFFEA3F74), size: 22),
            ),
            title: Text(
              e.titulo,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            subtitle: Text(
              '${e.dataFormatada} • ${e.localEvento}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabComunidades() {
    if (_userComunidades.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.groups_outlined,
        title: 'Nenhuma comunidade',
        subtitle: 'Você ainda não faz parte de nenhuma comunidade.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userComunidades.length,
      itemBuilder: (context, index) {
        final c = _userComunidades[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEEF2F7)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hub_rounded,
                  color: Color(0xFF16A34A), size: 22),
            ),
            title: Text(
              c.nome,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            subtitle: Text(
              '${c.totalMembros} membros',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
