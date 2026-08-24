import 'package:flutter/material.dart';
import '../models/comunidade.dart';
import '../services/comunidade_service.dart';
import '../services/auth_service.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final ComunidadeService _service = ComunidadeService();
  List<Comunidade> _comunidades = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarComunidades();
  }

  Future<void> _carregarComunidades() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _service.listarComunidades();
      if (mounted) {
        setState(() {
          _comunidades = lista;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar as comunidades.';
          _carregando = false;
        });
      }
    }
  }

  Future<void> _participar(Comunidade c) async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _snack('Faça login para participar de comunidades.',
          cor: const Color(0xFFEA3F74));
      return;
    }
    final ok = await _service.participarComunidade(
        c.id, AuthService.idUsuario!);
    _snack(
      ok
          ? 'Você entrou em "${c.nome}"!'
          : 'Não foi possível entrar na comunidade.',
      cor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
    );
    if (ok) _carregarComunidades();
  }

  Future<void> _sair(Comunidade c) async {
    if (!AuthService.logado || AuthService.idUsuario == null) return;
    final ok = await _service.sairComunidade(
        c.id, AuthService.idUsuario!, AuthService.idUsuario!);
    _snack(
      ok ? 'Você saiu de "${c.nome}".' : 'Não foi possível sair.',
      cor: ok ? const Color(0xFF64748B) : const Color(0xFFEF4444),
    );
    if (ok) _carregarComunidades();
  }

  void _snack(String msg, {Color cor = const Color(0xFF10B981)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: cor));
  }

  void _abrirCriarComunidade() {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _snack('Faça login para criar comunidades.',
          cor: const Color(0xFFEA3F74));
      return;
    }

    final nomeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
        child: SingleChildScrollView(
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
              const Text(
                'Nova Comunidade',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nomeCtrl,
                decoration: _modalInput(
                    'Nome da Comunidade', Icons.groups_rounded),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: _modalInput(
                    'Descrição e objetivos', Icons.info_outline_rounded),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA3F74),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  if (nomeCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Informe um nome para a comunidade.'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  final nova = await _service.criarComunidade(
                    nome: nomeCtrl.text.trim(),
                    descricao: descCtrl.text.trim(),
                    criadorId: AuthService.idUsuario!,
                  );
                  if (nova != null) {
                    _snack('Comunidade "${nova.nome}" criada!');
                    _carregarComunidades();
                  } else {
                    _snack('Erro ao criar comunidade.',
                        cor: const Color(0xFFEF4444));
                  }
                },
                child: const Text('Criar Comunidade',
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

  InputDecoration _modalInput(String label, IconData icon) {
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
        borderSide:
            const BorderSide(color: Color(0xFFEA3F74), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
    );
  }

  /// Ícone baseado no nome da comunidade (fallback inteligente)
  IconData _iconeParaComunidade(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('flutter') || n.contains('dev') || n.contains('code') || n.contains('tech')) {
      return Icons.code_rounded;
    }
    if (n.contains('design') || n.contains('ux') || n.contains('ui')) {
      return Icons.palette_rounded;
    }
    if (n.contains('game') || n.contains('esport') || n.contains('jog')) {
      return Icons.sports_esports_rounded;
    }
    if (n.contains('estudo') || n.contains('academ') || n.contains('tcc') || n.contains('integrad')) {
      return Icons.school_rounded;
    }
    if (n.contains('musica') || n.contains('música') || n.contains('arte')) {
      return Icons.music_note_rounded;
    }
    if (n.contains('sport') || n.contains('futebol') || n.contains('basquet')) {
      return Icons.sports_rounded;
    }
    return Icons.groups_rounded;
  }

  Color _corParaIndex(int index) {
    const cores = [
      Color(0xFFEA3F74),
      Color(0xFF2563EB),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
    ];
    return cores[index % cores.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _carregarComunidades,
        color: const Color(0xFFEA3F74),
        child: CustomScrollView(
          slivers: [
            // Header banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E2433), Color(0xFFEA3F74)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA3F74).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.hub_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Comunidades',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    'Conecte-se com grupos de interesses comuns',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: _abrirCriarComunidade,
                        icon: const Icon(Icons.group_add_rounded, size: 18),
                        label: const Text('Nova Comunidade',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E2433),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Subtítulo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _carregando
                          ? 'Carregando...'
                          : 'Comunidades (${_comunidades.length})',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A)),
                    ),
                    GestureDetector(
                      onTap: _carregarComunidades,
                      child: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF64748B), size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Conteúdo
            if (_carregando)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFEA3F74)),
                ),
              )
            else if (_erro != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 52, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(_erro!,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _carregarComunidades,
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
              )
            else if (_comunidades.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.groups_outlined,
                          size: 56, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      const Text('Nenhuma comunidade ainda',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _abrirCriarComunidade,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Criar Comunidade'),
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
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final c = _comunidades[index];
                      final bool isMembro =
                          c.isMembro(AuthService.idUsuario);
                      final cor = _corParaIndex(index);
                      final icone = _iconeParaComunidade(c.nome);

                      return _ComunidadeCard(
                        comunidade: c,
                        isMembro: isMembro,
                        cor: cor,
                        icone: icone,
                        onParticipar: () => _participar(c),
                        onSair: () => _sair(c),
                      );
                    },
                    childCount: _comunidades.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComunidadeCard extends StatelessWidget {
  final Comunidade comunidade;
  final bool isMembro;
  final Color cor;
  final IconData icone;
  final VoidCallback onParticipar;
  final VoidCallback onSair;

  const _ComunidadeCard({
    required this.comunidade,
    required this.isMembro,
    required this.cor,
    required this.icone,
    required this.onParticipar,
    required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEEF2F7), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icone, color: cor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comunidade.nome,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${comunidade.totalMembros} ${comunidade.totalMembros == 1 ? 'membro' : 'membros'}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isMembro)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Membro',
                        style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),

            if (comunidade.descricao != null &&
                comunidade.descricao!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                comunidade.descricao!,
                style: const TextStyle(
                    color: Color(0xFF475569), fontSize: 13, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (comunidade.criador != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    'Criado por ${comunidade.criador!.nome}',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: isMembro
                  ? OutlinedButton.icon(
                      onPressed: onSair,
                      icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                      label: const Text('Sair da Comunidade'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: onParticipar,
                      icon: const Icon(Icons.person_add_rounded, size: 16),
                      label: const Text('Participar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
