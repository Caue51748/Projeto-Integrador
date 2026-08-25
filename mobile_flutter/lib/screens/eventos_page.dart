import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../services/auth_service.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final EventoService _service = EventoService();
  List<Evento> _eventos = [];
  List<Evento> _eventosFiltrados = [];
  Map<int, int> _totalParticipantesPorEvento = {};
  Set<int> _eventosInscritos = {};

  bool _carregando = true;
  String? _erro;
  String _filtroStatus = 'TODOS';
  final TextEditingController _buscaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarEventos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.listarEventos();
      final Map<int, int> mapaContagem = {};
      final Set<int> inscritos = {};

      for (var ev in lista) {
        final total = await _service.contarParticipantes(ev.id);
        mapaContagem[ev.id] = total;

        if (AuthService.logado && AuthService.idUsuario != null) {
          final ids = await _service.listarIdsParticipantes(ev.id);
          if (ids.contains(AuthService.idUsuario)) {
            inscritos.add(ev.id);
          }
        }
      }

      if (mounted) {
        setState(() {
          _eventos = lista;
          _totalParticipantesPorEvento = mapaContagem;
          _eventosInscritos = inscritos;
          _carregando = false;
          _aplicarFiltros();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar os eventos da rede.';
          _carregando = false;
        });
      }
    }
  }

  void _aplicarFiltros() {
    final query = _buscaCtrl.text.trim().toLowerCase();
    setState(() {
      _eventosFiltrados = _eventos.where((ev) {
        final sit = ev.situacaoCalculada;
        final matchStatus = _filtroStatus == 'TODOS' ||
            (_filtroStatus == 'AGENDADO' && (sit == 'AGENDADO' || sit == 'ATIVO')) ||
            (_filtroStatus == 'ACONTECENDO_AGORA' && sit == 'ACONTECENDO_AGORA') ||
            (_filtroStatus == 'ENCERRADO' && sit == 'ENCERRADO') ||
            (_filtroStatus == 'INSCRITO' && _eventosInscritos.contains(ev.id));

        final matchTexto = query.isEmpty ||
            ev.titulo.toLowerCase().contains(query) ||
            ev.localEvento.toLowerCase().contains(query) ||
            (ev.descricao != null && ev.descricao!.toLowerCase().contains(query));

        return matchStatus && matchTexto;
      }).toList();
    });
  }

  Future<void> _toggleParticipacao(Evento evento) async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _mostrarSnack('Faça login para participar de eventos.',
          cor: const Color(0xFFEA3F74));
      return;
    }

    final userId = AuthService.idUsuario!;
    final jaInscrito = _eventosInscritos.contains(evento.id);

    if (jaInscrito) {
      // Sair do evento
      final ok = await _service.sairEvento(evento.id, userId);
      if (ok) {
        setState(() {
          _eventosInscritos.remove(evento.id);
          final atual = _totalParticipantesPorEvento[evento.id] ?? 1;
          _totalParticipantesPorEvento[evento.id] = (atual > 0) ? atual - 1 : 0;
        });
        _mostrarSnack('Você cancelou sua presença no evento.',
            cor: const Color(0xFF64748B));
      } else {
        _mostrarSnack('Não foi possível cancelar a presença.',
            cor: const Color(0xFFEF4444));
      }
    } else {
      // Ingressar no evento
      final ok = await _service.participarEvento(evento.id, userId);
      if (ok) {
        setState(() {
          _eventosInscritos.add(evento.id);
          final atual = _totalParticipantesPorEvento[evento.id] ?? 0;
          _totalParticipantesPorEvento[evento.id] = atual + 1;
        });
        _mostrarSnack('Presença confirmada em "${evento.titulo}"!',
            cor: const Color(0xFF10B981));
      } else {
        _mostrarSnack('Não foi possível confirmar presença.',
            cor: const Color(0xFFEF4444));
      }
    }
  }

  void _mostrarSnack(String msg, {Color cor = const Color(0xFF10B981)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: cor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _abrirCriarEvento() {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _mostrarSnack('Faça login para criar eventos.',
          cor: const Color(0xFFEA3F74));
      return;
    }

    final tituloCtrl = TextEditingController();
    final localCtrl = TextEditingController();
    final descricaoCtrl = TextEditingController();
    final limiteCtrl = TextEditingController();
    DateTime? dataSelecionada;
    TimeOfDay? horarioInicioSelecionado;
    TimeOfDay? horarioFimSelecionado;
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
                    Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFFEA3F74), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Novo Evento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _modalField(tituloCtrl, 'Título do Evento', Icons.event_rounded),
                const SizedBox(height: 12),
                _modalField(localCtrl, 'Local do Evento', Icons.location_on_outlined),
                const SizedBox(height: 12),
                _modalField(descricaoCtrl, 'Descrição detalhada', Icons.description_outlined,
                    maxLines: 3),
                const SizedBox(height: 12),

                // Data Picker
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setModalState(() => dataSelecionada = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFFEA3F74)),
                        const SizedBox(width: 10),
                        Text(
                          dataSelecionada != null
                              ? '${dataSelecionada!.day.toString().padLeft(2, '0')}/${dataSelecionada!.month.toString().padLeft(2, '0')}/${dataSelecionada!.year}'
                              : 'Selecionar data do evento',
                          style: TextStyle(
                            color: dataSelecionada != null
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: dataSelecionada != null ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horários Início e Fim
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 9, minute: 0));
                          if (t != null) {
                            setModalState(() => horarioInicioSelecionado = t);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  size: 16, color: Color(0xFFEA3F74)),
                              const SizedBox(width: 6),
                              Text(
                                horarioInicioSelecionado != null
                                    ? horarioInicioSelecionado!.format(ctx)
                                    : 'Início',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: horarioInicioSelecionado != null
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade500,
                                    fontWeight: horarioInicioSelecionado != null ? FontWeight.w600 : FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 18, minute: 0));
                          if (t != null) {
                            setModalState(() => horarioFimSelecionado = t);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_outlined,
                                  size: 16, color: Color(0xFFEA3F74)),
                              const SizedBox(width: 6),
                              Text(
                                horarioFimSelecionado != null
                                    ? horarioFimSelecionado!.format(ctx)
                                    : 'Fim',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: horarioFimSelecionado != null
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade500,
                                    fontWeight: horarioFimSelecionado != null ? FontWeight.w600 : FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _modalField(limiteCtrl, 'Limite de Participantes (opcional)', Icons.people_outline_rounded,
                    keyboardType: TextInputType.number),
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
                  onPressed: salvando
                      ? null
                      : () async {
                          if (tituloCtrl.text.trim().isEmpty ||
                              dataSelecionada == null ||
                              horarioInicioSelecionado == null ||
                              horarioFimSelecionado == null ||
                              localCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Preencha título, local, data e horários do evento.'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          setModalState(() => salvando = true);

                          final String dataStr =
                              '${dataSelecionada!.year}-${dataSelecionada!.month.toString().padLeft(2, '0')}-${dataSelecionada!.day.toString().padLeft(2, '0')}';
                          final String horInicioStr =
                              '${horarioInicioSelecionado!.hour.toString().padLeft(2, '0')}:${horarioInicioSelecionado!.minute.toString().padLeft(2, '0')}:00';
                          final String horFimStr =
                              '${horarioFimSelecionado!.hour.toString().padLeft(2, '0')}:${horarioFimSelecionado!.minute.toString().padLeft(2, '0')}:00';

                          final int? limite = int.tryParse(limiteCtrl.text.trim());
                          final nav = Navigator.of(ctx);

                          final evento = await _service.criarEvento({
                            'titulo': tituloCtrl.text.trim(),
                            'descricao': descricaoCtrl.text.trim().isEmpty
                                ? null
                                : descricaoCtrl.text.trim(),
                            'localEvento': localCtrl.text.trim(),
                            'dataEvento': dataStr,
                            'horarioInicio': horInicioStr,
                            'horarioFim': horFimStr,
                            'limiteParticipantes': limite,
                            'criadorId': AuthService.idUsuario,
                            'status': 'AGENDADO',
                            'exigeCheckin': false,
                          });

                          if (!mounted) return;
                          nav.pop();

                          if (evento != null) {
                            _mostrarSnack('Evento publicado com sucesso!');
                            _carregarEventos();
                          } else {
                            _mostrarSnack('Erro ao publicar evento no servidor.',
                                cor: const Color(0xFFEF4444));
                          }
                        },
                  child: salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Publicar Evento',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField(
      TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFFEA3F74)),
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
        labelStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'ACONTECENDO_AGORA':
        return const Color(0xFF10B981);
      case 'ENCERRADO':
        return const Color(0xFF94A3B8);
      case 'CANCELADO':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFEA3F74);
    }
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'ACONTECENDO_AGORA':
        return '🟢 Ao Vivo';
      case 'ENCERRADO':
        return 'Encerrado';
      case 'CANCELADO':
        return '❌ Cancelado';
      default:
        return 'Agendado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _carregarEventos,
        color: const Color(0xFFEA3F74),
        child: CustomScrollView(
          slivers: [
            // Header Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA3F74), Color(0xFFFF6B9D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA3F74).withValues(alpha: 0.3),
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
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_month_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Agenda de Eventos',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    'Encontros, palestras e experiências reais',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: _abrirCriarEvento,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Criar Evento',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFEA3F74),
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

            // Barra de Busca
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (_) => _aplicarFiltros(),
                  decoration: InputDecoration(
                    hintText: 'Buscar evento por título ou local...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 20, color: Color(0xFF94A3B8)),
                    suffixIcon: _buscaCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _buscaCtrl.clear();
                              _aplicarFiltros();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEEF2F7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEEF2F7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFEA3F74), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Chips de Filtro
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildFilterChip('TODOS', 'Todos'),
                    _buildFilterChip('AGENDADO', 'Agendados'),
                    _buildFilterChip('ACONTECENDO_AGORA', 'Ao Vivo'),
                    _buildFilterChip('ENCERRADO', 'Encerrados'),
                    if (AuthService.logado)
                      _buildFilterChip('INSCRITO', 'Minhas Inscrições'),
                  ],
                ),
              ),
            ),

            // Título da Lista
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _carregando
                          ? 'Carregando eventos...'
                          : 'Eventos (${_eventosFiltrados.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    GestureDetector(
                      onTap: _carregarEventos,
                      child: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF64748B), size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Estados da lista
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
                        onPressed: _carregarEventos,
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
            else if (_eventosFiltrados.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy_rounded,
                          size: 56, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      const Text('Nenhum evento encontrado',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Tente ajustar os filtros ou crie um novo.',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _abrirCriarEvento,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Criar Evento'),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ev = _eventosFiltrados[index];
                      final bool isInscrito = _eventosInscritos.contains(ev.id);
                      final int totalParticipantes =
                          _totalParticipantesPorEvento[ev.id] ?? 0;

                      return _EventoCard(
                        evento: ev,
                        isInscrito: isInscrito,
                        totalParticipantes: totalParticipantes,
                        onToggleParticipacao: () => _toggleParticipacao(ev),
                        corStatus: _corStatus,
                        labelStatus: _labelStatus,
                      );
                    },
                    childCount: _eventosFiltrados.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filtroStatus == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFEA3F74),
        side: BorderSide(
          color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (val) {
          setState(() {
            _filtroStatus = key;
            _aplicarFiltros();
          });
        },
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;
  final bool isInscrito;
  final int totalParticipantes;
  final VoidCallback onToggleParticipacao;
  final Color Function(String) corStatus;
  final String Function(String) labelStatus;

  const _EventoCard({
    required this.evento,
    required this.isInscrito,
    required this.totalParticipantes,
    required this.onToggleParticipacao,
    required this.corStatus,
    required this.labelStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = evento.situacaoCalculada;
    final cor = corStatus(status);
    final label = labelStatus(status);

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
            // Status + data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                        color: cor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  evento.dataFormatada,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Título
            Text(
              evento.titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            // Horário
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFFEA3F74)),
                const SizedBox(width: 6),
                Text(
                  '${evento.horarioFormatado} — ${evento.horarioFim.length >= 5 ? evento.horarioFim.substring(0, 5) : evento.horarioFim}',
                  style: const TextStyle(
                      color: Color(0xFF475569), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Local
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    evento.localEvento,
                    style: const TextStyle(
                        color: Color(0xFF475569), fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Participantes badge
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  '$totalParticipantes ${totalParticipantes == 1 ? 'participante' : 'participantes'}'
                  '${evento.limiteParticipantes != null ? ' (máx. ${evento.limiteParticipantes})' : ''}',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),

            // Descrição
            if (evento.descricao != null &&
                evento.descricao!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                evento.descricao!,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (status != 'ENCERRADO' && status != 'CANCELADO') ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: isInscrito
                    ? OutlinedButton.icon(
                        onPressed: onToggleParticipacao,
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 16, color: Color(0xFF10B981)),
                        label: const Text('Presença Confirmada (Cancelar)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: onToggleParticipacao,
                        icon: const Icon(Icons.event_available_rounded, size: 16),
                        label: const Text('Participar do Evento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA3F74),
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
          ],
        ),
      ),
    );
  }
}
