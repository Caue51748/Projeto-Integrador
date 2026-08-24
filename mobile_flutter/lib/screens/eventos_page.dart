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
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarEventos();
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar os eventos.';
          _carregando = false;
        });
      }
    }
  }

  Future<void> _participar(Evento evento) async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _mostrarSnack('Faça login para participar de eventos.',
          cor: const Color(0xFFEA3F74));
      return;
    }

    final ok = await _service.participarEvento(
        evento.id, AuthService.idUsuario!);

    _mostrarSnack(
      ok
          ? 'Presença confirmada em "${evento.titulo}"!'
          : 'Não foi possível confirmar presença.',
      cor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
    );
  }

  void _mostrarSnack(String msg, {Color cor = const Color(0xFF10B981)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: cor),
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
    DateTime? dataSelecionada;
    TimeOfDay? horarioInicioSelecionado;
    TimeOfDay? horarioFimSelecionado;

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
                  'Criar Evento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 20),

                _modalField(tituloCtrl, 'Título do Evento', Icons.event_rounded),
                const SizedBox(height: 12),
                _modalField(localCtrl, 'Local / Link', Icons.location_on_outlined),
                const SizedBox(height: 12),
                _modalField(descricaoCtrl, 'Descrição', Icons.description_outlined,
                    maxLines: 3),
                const SizedBox(height: 12),

                // Seletor de data
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
                            size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Text(
                          dataSelecionada != null
                              ? '${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}'
                              : 'Selecionar data',
                          style: TextStyle(
                            color: dataSelecionada != null
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horários
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
                                  size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                horarioInicioSelecionado != null
                                    ? horarioInicioSelecionado!.format(ctx)
                                    : 'Início',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: horarioInicioSelecionado != null
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade500),
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
                                  size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                horarioFimSelecionado != null
                                    ? horarioFimSelecionado!.format(ctx)
                                    : 'Fim',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: horarioFimSelecionado != null
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    if (tituloCtrl.text.trim().isEmpty ||
                        dataSelecionada == null ||
                        horarioInicioSelecionado == null ||
                        horarioFimSelecionado == null ||
                        localCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Preencha título, local, data e horários.'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    final String dataStr =
                        '${dataSelecionada!.year}-${dataSelecionada!.month.toString().padLeft(2, '0')}-${dataSelecionada!.day.toString().padLeft(2, '0')}';
                    final String horInicioStr =
                        '${horarioInicioSelecionado!.hour.toString().padLeft(2, '0')}:${horarioInicioSelecionado!.minute.toString().padLeft(2, '0')}:00';
                    final String horFimStr =
                        '${horarioFimSelecionado!.hour.toString().padLeft(2, '0')}:${horarioFimSelecionado!.minute.toString().padLeft(2, '0')}:00';

                    Navigator.pop(ctx);

                    final evento = await _service.criarEvento({
                      'titulo': tituloCtrl.text.trim(),
                      'descricao': descricaoCtrl.text.trim().isEmpty
                          ? null
                          : descricaoCtrl.text.trim(),
                      'localEvento': localCtrl.text.trim(),
                      'dataEvento': dataStr,
                      'horarioInicio': horInicioStr,
                      'horarioFim': horFimStr,
                      'criadorId': AuthService.idUsuario,
                      'status': 'AGENDADO',
                      'exigeCheckin': false,
                    });

                    if (evento != null) {
                      _mostrarSnack('Evento criado com sucesso!');
                      _carregarEventos();
                    } else {
                      _mostrarSnack('Erro ao criar evento.',
                          cor: const Color(0xFFEF4444));
                    }
                  },
                  child: const Text('Publicar Evento',
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
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
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
                                    'Fique por dentro das resenhas e encontros',
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

            // Título da lista
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _carregando
                          ? 'Carregando...'
                          : 'Eventos (${_eventos.length})',
                      style: const TextStyle(
                        fontSize: 17,
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

            // Estados: loading / erro / vazio / lista
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
            else if (_eventos.isEmpty)
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
                      Text('Seja o primeiro a criar um!',
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _EventoCard(
                          evento: _eventos[index],
                          onParticipar: () =>
                              _participar(_eventos[index]),
                          corStatus: _corStatus,
                          labelStatus: _labelStatus,
                        ),
                    childCount: _eventos.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onParticipar;
  final Color Function(String) corStatus;
  final String Function(String) labelStatus;

  const _EventoCard({
    required this.evento,
    required this.onParticipar,
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
                    color: cor.withValues(alpha: 0.1),
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
                child: OutlinedButton.icon(
                  onPressed: onParticipar,
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 16),
                  label: const Text('Participar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEA3F74),
                    side: const BorderSide(color: Color(0xFFEA3F74)),
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

