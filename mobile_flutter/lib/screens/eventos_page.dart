import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../services/auth_service.dart';

class EventosPage extends StatefulWidget {
  final VoidCallback? onVerMapa;

  const EventosPage({
    super.key,
    this.onVerMapa,
  });

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

      if (mounted) {
        setState(() {
          _eventos = lista;
          _carregando = false;
          _aplicarFiltros();
        });
      }

      // Carrega dados secundários (contagem e inscrições) em segundo plano sem bloquear a renderização dos eventos
      _carregarMetadadosEventos(lista);
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar os eventos da rede.';
          _carregando = false;
        });
      }
    }
  }

  Future<void> _carregarMetadadosEventos(List<Evento> lista) async {
    final Map<int, int> mapaContagem = Map.from(_totalParticipantesPorEvento);
    final Set<int> inscritos = Set.from(_eventosInscritos);

    for (var ev in lista) {
      try {
        final total = await _service.contarParticipantes(ev.id);
        mapaContagem[ev.id] = total;

        if (AuthService.logado && AuthService.idUsuario != null) {
          final ids = await _service.listarIdsParticipantes(ev.id);
          if (ids.contains(AuthService.idUsuario)) {
            inscritos.add(ev.id);
          }
        }
      } catch (_) {
        // Ignora falhas pontuais de contagem para manter os eventos visíveis na tela
      }
    }

    if (mounted) {
      setState(() {
        _totalParticipantesPorEvento = mapaContagem;
        _eventosInscritos = inscritos;
        _aplicarFiltros();
      });
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
      final ok = await _service.sairEvento(evento.id, userId);
      if (ok && mounted) {
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
      final ok = await _service.participarEvento(evento.id, userId);
      if (ok && mounted) {
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

  void _abrirDetalhesEventoModal(Evento evento) {
    final bool jaInscrito = _eventosInscritos.contains(evento.id);
    final int total = _totalParticipantesPorEvento[evento.id] ?? 0;
    final sit = evento.situacaoCalculada;
    final bool emAndamento = sit == 'ACONTECENDO_AGORA';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      evento.categoria ?? '🎉 EVENTO',
                      style: const TextStyle(
                        color: Color(0xFFEA3F74),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: emAndamento ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      emAndamento ? '🔥 ACONTECENDO AGORA' : 'STATUS: ${evento.status}',
                      style: TextStyle(
                        color: emAndamento ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                evento.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow(Icons.calendar_month_outlined, 'Data', evento.dataFormatada),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.schedule_outlined, 'Horário', '${evento.horarioFormatado} às ${evento.horarioFim.length >= 5 ? evento.horarioFim.substring(0, 5) : evento.horarioFim}'),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on_outlined, 'Local', evento.localEvento),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.people_outline_rounded, 'Participantes', '$total confirmados ${evento.limiteParticipantes != null ? "(máx. ${evento.limiteParticipantes})" : ""}'),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.verified_outlined, 'Entrada', evento.exigeCheckin ? 'Check-in obrigatório pelo app' : 'Entrada livre'),

              if (evento.descricao != null && evento.descricao!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Sobre o Evento', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text(
                  evento.descricao!,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.45),
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  if (widget.onVerMapa != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onVerMapa!();
                        },
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Ver no Mapa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  if (widget.onVerMapa != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _toggleParticipacao(evento);
                      },
                      icon: Icon(jaInscrito ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded, size: 18),
                      label: Text(jaInscrito ? 'Confirmado' : 'Participar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jaInscrito ? const Color(0xFF10B981) : const Color(0xFFEA3F74),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFEA3F74)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _abrirCriarEvento() {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _mostrarSnack('Faça login para criar eventos.', cor: const Color(0xFFEA3F74));
      return;
    }

    final tituloCtrl = TextEditingController();
    final localCtrl = TextEditingController();
    final descricaoCtrl = TextEditingController();
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
                    Icon(Icons.add_circle_outline_rounded, color: Color(0xFFEA3F74), size: 24),
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
                _modalField(descricaoCtrl, 'Descrição detalhada', Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 12),

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
                        const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFEA3F74)),
                        const SizedBox(width: 10),
                        Text(
                          dataSelecionada != null
                              ? '${dataSelecionada!.day.toString().padLeft(2, '0')}/${dataSelecionada!.month.toString().padLeft(2, '0')}/${dataSelecionada!.year}'
                              : 'Selecionar data do evento',
                          style: TextStyle(
                            color: dataSelecionada != null ? const Color(0xFF0F172A) : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 19, minute: 0));
                          if (t != null) setModalState(() => horarioInicioSelecionado = t);
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
                              const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFEA3F74)),
                              const SizedBox(width: 6),
                              Text(
                                horarioInicioSelecionado != null ? horarioInicioSelecionado!.format(ctx) : 'Início',
                                style: const TextStyle(fontSize: 13),
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
                              initialTime: const TimeOfDay(hour: 22, minute: 0));
                          if (t != null) setModalState(() => horarioFimSelecionado = t);
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
                              const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFEA3F74)),
                              const SizedBox(width: 6),
                              Text(
                                horarioFimSelecionado != null ? horarioFimSelecionado!.format(ctx) : 'Fim',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA3F74),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: salvando
                      ? null
                      : () async {
                          if (tituloCtrl.text.trim().isEmpty ||
                              localCtrl.text.trim().isEmpty ||
                              dataSelecionada == null ||
                              horarioInicioSelecionado == null) {
                            _mostrarSnack('Preencha os campos obrigatórios.', cor: const Color(0xFFEF4444));
                            return;
                          }

                          setModalState(() => salvando = true);

                          final ano = dataSelecionada!.year;
                          final mes = dataSelecionada!.month.toString().padLeft(2, '0');
                          final dia = dataSelecionada!.day.toString().padLeft(2, '0');
                          final dataIso = '$ano-$mes-$dia';

                          final hIni = '${horarioInicioSelecionado!.hour.toString().padLeft(2, '0')}:${horarioInicioSelecionado!.minute.toString().padLeft(2, '0')}:00';
                          final hFim = horarioFimSelecionado != null
                              ? '${horarioFimSelecionado!.hour.toString().padLeft(2, '0')}:${horarioFimSelecionado!.minute.toString().padLeft(2, '0')}:00'
                              : '${(horarioInicioSelecionado!.hour + 2) % 24}:${horarioInicioSelecionado!.minute.toString().padLeft(2, '0')}:00';

                          final novoEvento = await _service.criarEvento({
                            'titulo': tituloCtrl.text.trim(),
                            'localEvento': localCtrl.text.trim(),
                            'descricao': descricaoCtrl.text.trim().isEmpty ? null : descricaoCtrl.text.trim(),
                            'dataEvento': dataIso,
                            'horarioInicio': hIni,
                            'horarioFim': hFim,
                            'criadorId': AuthService.idUsuario,
                            'status': 'AGENDADO',
                            'exigeCheckin': false,
                          });

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (novoEvento != null) {
                              _mostrarSnack('Evento criado com sucesso! 🎉');
                              _carregarEventos();
                            } else {
                              _mostrarSnack('Erro ao criar evento.', cor: const Color(0xFFEF4444));
                            }
                          }
                        },
                  child: salvando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Criar Evento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
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
          borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: RefreshIndicator(
        onRefresh: _carregarEventos,
        color: const Color(0xFFEA3F74),
        child: CustomScrollView(
          slivers: [
            // Banner de Topo
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
                            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Agenda de Eventos', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                                Text('Encontros e experiências em tempo real', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _abrirCriarEvento,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Criar Evento', style: TextStyle(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFEA3F74),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                          if (widget.onVerMapa != null) ...[
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: widget.onVerMapa,
                              icon: const Icon(Icons.map_outlined, size: 18, color: Colors.white),
                              label: const Text('Ver no Mapa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Campo de Pesquisa
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (_) => _aplicarFiltros(),
                  decoration: InputDecoration(
                    hintText: 'Buscar evento por título ou local...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEEF2F7))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEEF2F7))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEA3F74), width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    _buildFilterChip('ACONTECENDO_AGORA', '🔥 Ao Vivo'),
                    _buildFilterChip('ENCERRADO', 'Encerrados'),
                    if (AuthService.logado) _buildFilterChip('INSCRITO', 'Minhas Inscrições'),
                  ],
                ),
              ),
            ),

            // Header Contador da Lista
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _carregando ? 'Carregando eventos...' : 'Eventos (${_eventosFiltrados.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    GestureDetector(
                      onTap: _carregarEventos,
                      child: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de Cards de Eventos
            if (_carregando)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFFEA3F74))),
              )
            else if (_erro != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(_erro!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _carregarEventos,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Tentar novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA3F74),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      const Icon(Icons.event_busy_rounded, size: 56, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      const Text('Nenhum evento encontrado', style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Tente ajustar os filtros ou crie um novo.', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ev = _eventosFiltrados[index];
                      final bool isInscrito = _eventosInscritos.contains(ev.id);
                      final int totalParticipantes = _totalParticipantesPorEvento[ev.id] ?? 0;

                      return _buildMobileTicketEventCard(ev, totalParticipantes, isInscrito);
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
        side: BorderSide(color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFFE2E8F0)),
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

  /// Card Estilo Ingresso Social para Eventos
  Widget _buildMobileTicketEventCard(Evento evento, int total, bool jaInscrito) {
    final sit = evento.situacaoCalculada;
    final bool emAndamento = sit == 'ACONTECENDO_AGORA';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: jaInscrito ? const Color(0xFFF9ACC6) : const Color(0xFFE2E8F0),
          width: jaInscrito ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _abrirDetalhesEventoModal(evento),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Estilo Ticket de Entrada no Lado Esquerdo
                  Container(
                    width: 54,
                    height: 58,
                    decoration: BoxDecoration(
                      color: emAndamento ? const Color(0xFFFEF2F2) : const Color(0xFFFDF0F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: emAndamento ? const Color(0xFFFCA5A5) : const Color(0xFFF9ACC6),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          emAndamento ? Icons.local_fire_department_rounded : Icons.event_rounded,
                          color: emAndamento ? const Color(0xFFEF4444) : const Color(0xFFEA3F74),
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          emAndamento ? 'AGORA' : 'EVENTO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: emAndamento ? const Color(0xFFDC2626) : const Color(0xFFEA3F74),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Título e Informações Principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                evento.localEvento,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (evento.descricao != null && evento.descricao!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  evento.descricao!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),

              // Rodapé com Avatares de Participantes e Botão de Presença
              Row(
                children: [
                  // Pilha de Avatares Sobrepostos
                  SizedBox(
                    width: 44,
                    height: 22,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFFF9ACC6),
                            child: const Text('E', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Positioned(
                          left: 11,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFFEA3F74),
                            child: const Text('V', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Positioned(
                          left: 22,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFF0F172A),
                            child: const Text('P', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$total confirmados',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),

                  // Botão Estilo Pílula
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _toggleParticipacao(evento),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jaInscrito ? const Color(0xFFECFDF5) : const Color(0xFFEA3F74),
                        foregroundColor: jaInscrito ? const Color(0xFF10B981) : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: jaInscrito ? const Color(0xFFA7F3D0) : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            jaInscrito ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                            size: 16,
                            color: jaInscrito ? const Color(0xFF10B981) : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            jaInscrito ? 'Confirmado' : 'Participar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: jaInscrito ? const Color(0xFF047857) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
