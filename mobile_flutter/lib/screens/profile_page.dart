import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/usuario.dart';
import '../models/post.dart';
import '../models/evento.dart';
import '../models/comunidade.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../services/post_service.dart';
import '../services/evento_service.dart';
import '../services/comunidade_service.dart';
import '../services/api_service.dart';
import '../services/seguimento_service.dart';
import '../widgets/social_avatar.dart';
import 'seguidores_page.dart';
import 'public_profile_page.dart';
import 'configuracoes_social_page.dart';
import 'post_detail_screen.dart';
import 'home_screen.dart';

/// Tela de Perfil Mobile — Fiel à Estilização Real da Tela WEB (.perfil-tabs, .perfil-tab.active::after, .avatar, .card, .btn-primary).
/// Fonte da Verdade: web/style.css
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
  final SeguimentoService _seguimentoService = SeguimentoService();
  int _seguidores = 0;
  int _seguindo = 0;
  List<Usuario> _sugestoes = [];
  final Set<int> _idsSeguindo = {};
  bool _carregandoSeguimento = false;
  List<Post> _userPosts = [];
  List<Evento> _userEventos = [];
  List<Comunidade> _userComunidades = [];

  bool _carregando = true;
  bool _enviandoFoto = false;
  String? _erro;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarDadosCompletos();
    _carregarSocial();
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
      final eventosFuture = _eventoService.listarEventosPorUsuario(id).catchError((_) => <Evento>[]);
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
            _usuario = Usuario(
              idUsuario: AuthService.idUsuario,
              nome: AuthService.nomeUsuario ?? 'Usuário',
              email: AuthService.emailUsuario ?? '',
              senha: '',
              username: AuthService.username,
              bio: AuthService.bio,
            );
          } else {
            if (_usuario!.nome.isNotEmpty) {
              AuthService.nomeUsuario = _usuario!.nome;
            }
            if (_usuario!.username != null) {
              AuthService.username = _usuario!.username;
            }
            if (_usuario!.bio != null) {
              AuthService.bio = _usuario!.bio;
            }
            AuthService.fotoPerfil = _usuario!.fotoPerfil;
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

  Future<void> _alterarFotoPerfil() async {
    if (!AuthService.logado || AuthService.idUsuario == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) return;

      final length = await picked.length();
      if (length > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A imagem deve ter no máximo 5 MB.',
                  style: GoogleFonts.manrope()),
              backgroundColor: const Color(0xFFC93659),
            ),
          );
        }
        return;
      }

      setState(() => _enviandoFoto = true);

      final bytes = await picked.readAsBytes();
      final res = await _usuarioService.atualizarFotoPerfil(
        idUsuario: AuthService.idUsuario!,
        caminhoArquivo: picked.path,
        bytes: bytes,
        nomeArquivo: picked.name,
      );

      if (!mounted) return;
      setState(() => _enviandoFoto = false);

      if (res['sucesso'] == true && res['usuario'] != null) {
        final Usuario userAtualizado = res['usuario'];
        setState(() {
          _usuario?.fotoPerfil = userAtualizado.fotoPerfil;
        });
        AuthService.fotoPerfil = userAtualizado.fotoPerfil;
        final url = ApiService.formatarUrlFotoPerfil(userAtualizado.fotoPerfil);
        if (url != null) {
          await NetworkImage(url).evict(); // evita cache da foto antiga
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto de perfil atualizada com sucesso!',
                style: GoogleFonts.manrope()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['erro'] ?? 'Erro ao alterar foto.',
                style: GoogleFonts.manrope()),
            backgroundColor: const Color(0xFFC93659),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _enviandoFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto.',
                style: GoogleFonts.manrope()),
            backgroundColor: const Color(0xFFC93659),
          ),
        );
      }
    }
  }

  Future<void> _carregarSocial() async {
    final id = AuthService.idUsuario;
    if (!mounted || id == null || _carregandoSeguimento) return;
    _carregandoSeguimento = true;
    try {
      final resumo = await _seguimentoService.resumo(id);
      final idsSeguindo = await _seguimentoService.ids(id, seguidores: false);
      final usuarios = await _usuarioService.listarUsuarios();
      if (!mounted) return;
      setState(() {
        _seguidores = resumo.seguidores;
        _seguindo = resumo.seguindo;
        _idsSeguindo..clear()..addAll(idsSeguindo);
        _sugestoes = usuarios.where((u) => u.idUsuario != null &&
            u.idUsuario != id && !_idsSeguindo.contains(u.idUsuario))
            .take(8).toList();
      });
    } catch (e) {
      // O feed e o perfil continuam disponíveis caso o novo módulo não esteja iniciado.
      debugPrint('Seguimentos indisponíveis: $e');
    } finally {
      _carregandoSeguimento = false;
    }
  }

  Future<void> _seguirSugestao(Usuario usuario) async {
    final meuId = AuthService.idUsuario;
    final id = usuario.idUsuario;
    if (meuId == null || id == null) return;
    try {
      await _seguimentoService.alterar(meuId: meuId, outroId: id, seguir: true);
      if (!mounted) return;
      setState(() {
        _idsSeguindo.add(id);
        _seguindo++;
        _sugestoes.removeWhere((u) => u.idUsuario == id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível seguir: $e')),
        );
      }
    }
  }

  void _abrirSeguimentos({required bool seguidores}) {
    final id = AuthService.idUsuario;
    if (id == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SeguidoresPage(usuarioId: id, seguidores: seguidores),
    )).then((_) => _carregarSocial());
  }

  Future<void> _abrirConfiguracoes() async {
    final usuario = _usuario;
    if (usuario == null) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) => ConfiguracoesSocialPage(
        usuario: usuario,
        onEditar: () { Navigator.pop(ctx); _abrirEditar(); },
        onAlterarFoto: () { Navigator.pop(ctx); _alterarFotoPerfil(); },
        onSair: () {
          AuthService.fazerLogout();
          Navigator.of(ctx).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
        },
      ),
    ));
  }

  Widget _sugestoesPerfis() {
    if (_sugestoes.isEmpty) return const SizedBox.shrink();
    return Container(color: Colors.white,
      padding: const EdgeInsets.fromLTRB(17, 14, 0, 19),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pessoas para conhecer', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF222631))),
        const SizedBox(height: 5),
        const Text('Encontre novos perfis no SocialJoin',
          style: TextStyle(fontSize: 12, color: Color(0xFF818596))),
        const SizedBox(height: 14),
        SizedBox(height: 153, child: ListView.separated(
          padding: const EdgeInsets.only(right: 18),
          scrollDirection: Axis.horizontal,
          itemCount: _sugestoes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final usuario = _sugestoes[i];
            return Container(width: 144, padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFECECF0))),
              child: Column(children: [
                InkWell(onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PublicProfilePage(usuarioId: usuario.idUsuario!))),
                  child: SocialAvatar(nome: usuario.nome,
                    foto: usuario.fotoPerfil, radius: 27)),
                const SizedBox(height: 5),
                Text(usuario.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                Text('@${usuario.username ?? ''}', maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF848A99))),
                const Spacer(),
                SizedBox(height: 29, width: double.infinity,
                  child: FilledButton(onPressed: () => _seguirSugestao(usuario),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEA3F74),
                      padding: EdgeInsets.zero, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
                    child: const Text('Seguir', style: TextStyle(fontSize: 12))),
                ),
              ]),
            );
          },
        )),
      ]),
    );
  }

  void _abrirEditar() {
    if (_usuario == null) return;

    final nomeCtrl = TextEditingController(text: _usuario!.nome);
    final usernameCtrl = TextEditingController(text: _usuario!.username ?? '');
    final bioCtrl = TextEditingController(text: _usuario!.bio ?? '');
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SingleChildScrollView(child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Editar Perfil',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nomeCtrl,
                style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF202124)),
                decoration: _inputDecoration('Nome Completo', Icons.person_outline_rounded),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: usernameCtrl,
                maxLength: 30,
                autocorrect: false,
                decoration: _inputDecoration('Nome de usuário (@)', Icons.alternate_email_rounded),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                maxLength: 300,
                style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF202124)),
                decoration: _inputDecoration('Biografia (opcional)', Icons.info_outline_rounded),
              ),
              const SizedBox(height: 6),

              Text(
                'O nome de usuário deve ser único na rede.',
                style: GoogleFonts.manrope(color: const Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA3F74),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: salvando
                      ? null
                      : () async {
                          if (nomeCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('O nome não pode ser vazio.', style: GoogleFonts.manrope()),
                                backgroundColor: const Color(0xFFC93659),
                              ),
                            );
                            return;
                          }

                          final novoUsername = usernameCtrl.text.trim().replaceFirst(RegExp(r'^@'), '');
                          if (!RegExp(r'^[a-zA-Z0-9._]{3,30}$').hasMatch(novoUsername)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Use de 3 a 30 caracteres: letras, números, ponto ou _.')));
                            return;
                          }
                          setModal(() => salvando = true);

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);

                          final ok = await _usuarioService.atualizarPerfil(
                            AuthService.idUsuario!,
                            nomeCtrl.text.trim(),
                            bioCtrl.text.trim(),
                            novoUsername: novoUsername,
                          );

                          if (!mounted) return;
                          nav.pop();

                          if (ok) {
                            AuthService.nomeUsuario = nomeCtrl.text.trim();
                            AuthService.bio = bioCtrl.text.trim();
                            AuthService.username = novoUsername;

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Perfil atualizado com sucesso!', style: GoogleFonts.manrope()),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );

                            _carregarDadosCompletos();
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(_usuarioService.ultimoErroAtualizacaoPerfil ?? 'Erro ao salvar.', style: GoogleFonts.manrope()),
                                backgroundColor: const Color(0xFFC93659),
                              ),
                            );
                          }
                        },
                  child: salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Salvar Alterações',
                          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        )),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFFEA3F74)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: GoogleFonts.manrope(color: const Color(0xFF6B7280), fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA3F74)))
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
            const Icon(Icons.person_off_rounded, size: 52, color: Color(0xFF6B7280)),
            const SizedBox(height: 16),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(color: const Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (AuthService.logado)
              ElevatedButton(
                onPressed: _carregarDadosCompletos,
                child: const Text('Tentar novamente'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfil() {
    final usuario = _usuario!;
    final inicial = usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : 'U';
    final foto = ApiService.formatarUrlFotoPerfil(usuario.fotoPerfil);

    return RefreshIndicator(
      onRefresh: () async { await _carregarDadosCompletos(); await _carregarSocial(); },
      color: const Color(0xFFEA3F74),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(19, 18, 19, 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(
                  usuario.username == null || usuario.username!.isEmpty
                      ? usuario.nome
                      : '@${usuario.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800,
                    color: const Color(0xFF202124)),
                )),
                IconButton(
                  tooltip: 'Configurações',
                  onPressed: _abrirConfiguracoes,
                  icon: const Icon(Icons.settings_outlined, color: Color(0xFF202124)),
                ),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                Stack(clipBehavior: Clip.none, children: [
                  InkWell(
                    onTap: _enviandoFoto ? null : _alterarFotoPerfil,
                    borderRadius: BorderRadius.circular(60),
                    child: CircleAvatar(
                      radius: 43,
                      backgroundColor: const Color(0xFFFFEAF1),
                      child: _enviandoFoto
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : foto == null
                              ? Text(inicial, style: GoogleFonts.manrope(
                                  fontSize: 31, fontWeight: FontWeight.w800,
                                  color: const Color(0xFFEA3F74)))
                              : ClipOval(child: Image.network(
                                  foto,
                                  width: 86,
                                  height: 86,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(inicial, style: GoogleFonts.manrope(
                                      fontSize: 31, fontWeight: FontWeight.w800,
                                      color: const Color(0xFFEA3F74),
                                    )),
                                  ),
                                )),
                    ),
                  ),
                  Positioned(bottom: -2, right: -3,
                    child: InkWell(
                      onTap: _enviandoFoto ? null : _alterarFotoPerfil,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA3F74), shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 17),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(width: 19),
                Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _buildStatItem('posts', '${_userPosts.length}'),
                  _statClicavel('seguidores', '$_seguidores', () => _abrirSeguimentos(seguidores: true)),
                  _statClicavel('seguindo', '$_seguindo', () => _abrirSeguimentos(seguidores: false)),
                ])),
              ]),
              const SizedBox(height: 17),
              Text(usuario.nome, style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800, fontSize: 15,
                color: const Color(0xFF202124))),
              if (usuario.bio != null && usuario.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(usuario.bio!, style: GoogleFonts.manrope(
                  fontSize: 13, height: 1.5, color: const Color(0xFF202124))),
              ],
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: _abrirEditar,
                  child: const Text('Editar perfil'),
                )),
                const SizedBox(width: 9),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _enviandoFoto ? null : _alterarFotoPerfil,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: Text(_enviandoFoto ? 'Enviando...' : 'Alterar foto'),
                )),
              ]),
            ]),
          )),
          SliverToBoxAdapter(child: _sugestoesPerfis()),
          // Abas de posts, eventos, comunidades e informações.
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFEA3F74),
                indicatorWeight: 3,
                labelColor: const Color(0xFFEA3F74),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on_rounded), iconMargin: EdgeInsets.zero),
                  Tab(icon: Icon(Icons.event_outlined), iconMargin: EdgeInsets.zero),
                  Tab(icon: Icon(Icons.groups_outlined), iconMargin: EdgeInsets.zero),
                  Tab(icon: Icon(Icons.person_outline_rounded), iconMargin: EdgeInsets.zero),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabPosts(),
            _buildTabEventos(),
            _buildTabComunidades(),
            _buildTabSobre(usuario),
          ],
        ),
      ),
    );
  }

  Widget _statClicavel(String label, String value, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: _buildStatItem(label, value)));
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            color: const Color(0xFF202124),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSobre(Usuario usuario) {
    final emailExibicao = (usuario.email.isNotEmpty)
        ? usuario.email
        : (AuthService.emailUsuario ?? 'Não informado');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _infoItem(Icons.person_outline_rounded, 'Nome Completo', usuario.nome),
                _divider(),
                _infoItem(Icons.alternate_email_rounded, 'Nome de Usuário', usuario.username != null ? '@${usuario.username}' : 'Não definido'),
                _divider(),
                _infoItem(Icons.email_outlined, 'E-mail', emailExibicao),
                if (usuario.bio != null && usuario.bio!.isNotEmpty) ...[
                  _divider(),
                  _infoItem(Icons.info_outline_rounded, 'Biografia', usuario.bio!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botão Logout
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text('Sair da conta', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 18)),
                    content: Text('Tem certeza que deseja sair?', style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF6B7280))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancelar', style: GoogleFonts.manrope(color: const Color(0xFF6B7280))),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC93659),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          AuthService.fazerLogout();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text('Sair da conta', style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC93659),
                side: const BorderSide(color: Color(0xFFF2B9C9)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPosts() {
    if (_userPosts.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.grid_on_rounded,
        title: 'Nenhuma publicação',
        subtitle: 'Suas publicações aparecerão aqui.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, i) {
        final post = _userPosts[i];
        final imagem = ApiService.formatarUrlMidia(post.imagemUrl);
        return Material(
          color: const Color(0xFFFFF1F6),
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PostDetailScreen(
                post: post,
                nomeAutor: _usuario?.nome ?? 'Usuário',
                nomesUsuarios: {
                  if (AuthService.idUsuario != null) AuthService.idUsuario!: _usuario?.nome ?? 'Usuário',
                },
              ),
            )),
            child: Stack(fit: StackFit.expand, children: [
              if (imagem != null)
                Image.network(imagem, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: Color(0xFFEA3F74)),
                  ))
              else
                Padding(padding: const EdgeInsets.all(10),
                  child: Center(child: Text(post.titulo,
                    maxLines: 4, overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800,
                      color: const Color(0xFF202124), fontSize: 12))),
                ),
            ]),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _userEventos.length,
      itemBuilder: (context, index) {
        final e = _userEventos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event, color: Color(0xFFEA3F74), size: 20),
            ),
            title: Text(
              e.titulo,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: const Color(0xFF202124), fontSize: 14),
            ),
            subtitle: Text(
              '${e.dataFormatada} • ${e.localEvento}',
              style: GoogleFonts.manrope(color: const Color(0xFF6B7280), fontSize: 12),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _userComunidades.length,
      itemBuilder: (context, index) {
        final c = _userComunidades[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_rounded, color: Color(0xFFEA3F74), size: 20),
            ),
            title: Text(
              c.nome,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: const Color(0xFF202124), fontSize: 14),
            ),
            subtitle: Text(
              '${c.totalMembros} membros',
              style: GoogleFonts.manrope(color: const Color(0xFF6B7280), fontSize: 12),
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
            Icon(icon, size: 48, color: const Color(0xFF6B7280)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(color: const Color(0xFF6B7280), fontSize: 13),
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
                  style: GoogleFonts.manrope(
                      color: const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                      color: const Color(0xFF202124),
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
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB), indent: 16);
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
