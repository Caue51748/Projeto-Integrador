import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../services/auth_service.dart';

class MapEventsPage extends StatefulWidget {
  const MapEventsPage({super.key});

  @override
  State<MapEventsPage> createState() => _MapEventsPageState();
}

class _MapEventsPageState extends State<MapEventsPage> {
  late final MapController _mapController;
  final EventoService _eventoService = EventoService();

  List<Evento> _eventosReais = [];
  Map<int, LatLng> _coordenadasEventos = {};
  Map<int, int> _participantesContagem = {};
  Set<int> _eventosInscritos = {};

  int _selectedEventIndex = 0;
  bool _carregando = true;
  String? _erro;

  // Pontos de referência para distribuir os locais de eventos caso não tenham coordenadas exatas
  final List<LatLng> _locaisReferencia = const [
    LatLng(-23.5615, -46.6560), // Av Paulista
    LatLng(-23.5855, -46.6815), // Faria Lima
    LatLng(-23.5874, -46.6576), // Ibirapuera
    LatLng(-23.5165, -46.6186), // Expo Center Norte
    LatLng(-23.5489, -46.6388), // Centro SP
    LatLng(-23.5505, -46.6333), // Sé
    LatLng(-23.5700, -46.6400), // Paraíso
    LatLng(-23.6000, -46.6900), // Berrini
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _eventoService.listarEventos();
      final Map<int, LatLng> mapaCoords = {};
      final Map<int, int> mapaParticipantes = {};
      final Set<int> inscritos = {};

      for (int i = 0; i < lista.length; i++) {
        final ev = lista[i];
        final coord = _locaisReferencia[i % _locaisReferencia.length];
        mapaCoords[ev.id] = coord;

        final total = await _eventoService.contarParticipantes(ev.id);
        mapaParticipantes[ev.id] = total;

        if (AuthService.logado && AuthService.idUsuario != null) {
          final ids = await _eventoService.listarIdsParticipantes(ev.id);
          if (ids.contains(AuthService.idUsuario)) {
            inscritos.add(ev.id);
          }
        }
      }

      if (mounted) {
        setState(() {
          _eventosReais = lista;
          _coordenadasEventos = mapaCoords;
          _participantesContagem = mapaParticipantes;
          _eventosInscritos = inscritos;
          _carregando = false;
          _selectedEventIndex = 0;
        });

        if (lista.isNotEmpty) {
          final firstCoord = mapaCoords[lista[0].id] ?? _locaisReferencia[0];
          _mapController.move(firstCoord, 13.5);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar os eventos no mapa.';
          _carregando = false;
        });
      }
    }
  }

  void _recenterToEvent(int index) {
    if (index < 0 || index >= _eventosReais.length) return;
    setState(() {
      _selectedEventIndex = index;
    });
    final ev = _eventosReais[index];
    final coord = _coordenadasEventos[ev.id] ?? _locaisReferencia[0];
    _mapController.move(coord, 14.5);
  }

  Future<void> _toggleParticipacao(Evento evento) async {
    if (!AuthService.logado || AuthService.idUsuario == null) {
      _snack('Faça login para participar de eventos.', cor: const Color(0xFFEA3F74));
      return;
    }

    final userId = AuthService.idUsuario!;
    final jaInscrito = _eventosInscritos.contains(evento.id);

    if (jaInscrito) {
      final ok = await _eventoService.sairEvento(evento.id, userId);
      if (ok) {
        setState(() {
          _eventosInscritos.remove(evento.id);
          final atual = _participantesContagem[evento.id] ?? 1;
          _participantesContagem[evento.id] = (atual > 0) ? atual - 1 : 0;
        });
        _snack('Presença cancelada.', cor: const Color(0xFF64748B));
      }
    } else {
      final ok = await _eventoService.participarEvento(evento.id, userId);
      if (ok) {
        setState(() {
          _eventosInscritos.add(evento.id);
          final atual = _participantesContagem[evento.id] ?? 0;
          _participantesContagem[evento.id] = atual + 1;
        });
        _snack('Presença confirmada!', cor: const Color(0xFF10B981));
      }
    }
  }

  void _snack(String msg, {Color cor = const Color(0xFF10B981)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: cor, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFEA3F74)),
              SizedBox(height: 16),
              Text('Carregando mapa de eventos reais...',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_erro != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded, size: 52, color: Color(0xFFCBD5E1)),
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
      );
    }

    if (_eventosReais.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 56, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 12),
              const Text('Nenhum evento cadastrado no sistema',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Crie eventos na tela de Eventos para visualizá-los no mapa.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _carregarEventos,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Atualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA3F74),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedEvent = _eventosReais[_selectedEventIndex];
    final bool isInscrito = _eventosInscritos.contains(selectedEvent.id);
    final int participantes = _participantesContagem[selectedEvent.id] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // MAPA INTERATIVO (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-23.5615, -46.6560),
              initialZoom: 13.0,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.socialjoin.app',
              ),
              MarkerLayer(
                markers: _eventosReais.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Evento event = entry.value;
                  final bool isSelected = index == _selectedEventIndex;
                  final LatLng coord = _coordenadasEventos[event.id] ?? _locaisReferencia[0];

                  return Marker(
                    width: isSelected ? 64 : 48,
                    height: isSelected ? 72 : 56,
                    point: coord,
                    child: GestureDetector(
                      onTap: () => _recenterToEvent(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFFEA3F74).withValues(alpha: 0.45)
                                      : Colors.black26,
                                  blurRadius: isSelected ? 10 : 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  event.titulo.length > 12
                                      ? '${event.titulo.substring(0, 10)}...'
                                      : event.titulo,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSelected ? 11 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFF0F172A),
                            size: isSelected ? 24 : 18,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Header com contador e botão de atualização
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_rounded, color: Color(0xFFEA3F74), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_eventosReais.length} ${_eventosReais.length == 1 ? 'evento real' : 'eventos reais'}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FloatingActionButton.small(
                  heroTag: 'refresh_map',
                  onPressed: _carregarEventos,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEA3F74),
                  child: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),

          // Controles de Zoom
          Positioned(
            right: 16,
            top: 76,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'recenter',
                  onPressed: () => _recenterToEvent(_selectedEventIndex),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEA3F74),
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // Card Inferior com Dados Reais do Evento Selecionado
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0F4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFCBD8)),
                          ),
                          child: Text(
                            selectedEvent.situacaoCalculada,
                            style: const TextStyle(
                              color: Color(0xFFEA3F74),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          selectedEvent.dataFormatada,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedEvent.titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedEvent.localEvento,
                            style: const TextStyle(
                                color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 15, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          '$participantes ${participantes == 1 ? 'participante confirmado' : 'participantes confirmados'}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: isInscrito
                              ? OutlinedButton.icon(
                                  onPressed: () => _toggleParticipacao(selectedEvent),
                                  icon: const Icon(Icons.check_circle_rounded,
                                      size: 16, color: Color(0xFF10B981)),
                                  label: const Text('Inscrito (Cancelar)'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF10B981),
                                    side: const BorderSide(color: Color(0xFF10B981)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => _toggleParticipacao(selectedEvent),
                                  icon: const Icon(Icons.event_available_rounded, size: 16),
                                  label: const Text('Participar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEA3F74),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
