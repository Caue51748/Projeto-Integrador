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
  List<Evento> _eventosFiltrados = [];
  Map<int, LatLng> _coordenadasEventos = {};
  Map<int, int> _participantesContagem = {};
  Set<int> _eventosInscritos = {};

  int _selectedEventIndex = 0;
  String _selectedCategory = 'Todos';
  bool _carregando = true;
  String? _erro;

  final List<String> _categorias = const [
    'Todos',
    'Tecnologia',
    'Design',
    'Games',
    'Acadêmico',
    'Comunidade',
  ];

  // Coordenadas geográficas de referência para distribuição dos eventos na região metropolitana de São Paulo
  final List<LatLng> _locaisReferencia = const [
    LatLng(-23.5615, -46.6560), // Av. Paulista
    LatLng(-23.5855, -46.6815), // Faria Lima
    LatLng(-23.5874, -46.6576), // Parque Ibirapuera
    LatLng(-23.5165, -46.6186), // Expo Center Norte
    LatLng(-23.5489, -46.6388), // Centro Histórico
    LatLng(-23.5505, -46.6333), // Praça da Sé
    LatLng(-23.5700, -46.6400), // Paraíso
    LatLng(-23.6000, -46.6900), // Eng. Luís Carlos Berrini
    LatLng(-23.5550, -46.6620), // Jardins
    LatLng(-23.5350, -46.6750), // Barra Funda / Perdizes
  ];

  final List<String> _distanciasMock = const [
    '1.2 km',
    '2.5 km',
    '3.8 km',
    '4.2 km',
    '5.6 km',
    '7.1 km',
    '8.4 km',
    '9.9 km',
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
          _aplicarFiltroCategoria();
        });

        if (_eventosFiltrados.isNotEmpty) {
          final firstCoord = mapaCoords[_eventosFiltrados[0].id] ?? _locaisReferencia[0];
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

  String _detectarCategoria(Evento ev) {
    final text = '${ev.titulo} ${ev.descricao ?? ''} ${ev.localEvento}'.toLowerCase();
    if (text.contains('tech') || text.contains('dev') || text.contains('flutter') || text.contains('código') || text.contains('hackathon')) {
      return 'Tecnologia';
    }
    if (text.contains('design') || text.contains('ui') || text.contains('ux') || text.contains('arte') || text.contains('figma')) {
      return 'Design';
    }
    if (text.contains('game') || text.contains('jogo') || text.contains('esport') || text.contains('play')) {
      return 'Games';
    }
    if (text.contains('acadêmico') || text.contains('academico') || text.contains('aula') || text.contains('palestra') || text.contains('curso') || text.contains('workshop') || text.contains('tcc')) {
      return 'Acadêmico';
    }
    return 'Comunidade';
  }

  void _aplicarFiltroCategoria() {
    setState(() {
      if (_selectedCategory == 'Todos') {
        _eventosFiltrados = List.from(_eventosReais);
      } else {
        _eventosFiltrados = _eventosReais.where((ev) {
          return _detectarCategoria(ev) == _selectedCategory;
        }).toList();
      }
      _selectedEventIndex = 0;
    });

    if (_eventosFiltrados.isNotEmpty) {
      final ev = _eventosFiltrados[0];
      final coord = _coordenadasEventos[ev.id] ?? _locaisReferencia[0];
      _mapController.move(coord, 14.0);
    }
  }

  void _recenterToEvent(int index) {
    if (index < 0 || index >= _eventosFiltrados.length) return;
    setState(() {
      _selectedEventIndex = index;
    });
    final ev = _eventosFiltrados[index];
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
        _snack('Presença cancelada com sucesso.', cor: const Color(0xFF64748B));
      }
    } else {
      final ok = await _eventoService.participarEvento(evento.id, userId);
      if (ok) {
        setState(() {
          _eventosInscritos.add(evento.id);
          final atual = _participantesContagem[evento.id] ?? 0;
          _participantesContagem[evento.id] = atual + 1;
        });
        _snack('Presença confirmada em "${evento.titulo}"!', cor: const Color(0xFF10B981));
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
              Text('Carregando mapa interativo...',
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

    final bool hasEvents = _eventosFiltrados.isNotEmpty;
    final Evento? selectedEvent = hasEvents && _selectedEventIndex < _eventosFiltrados.length
        ? _eventosFiltrados[_selectedEventIndex]
        : null;
    final bool isInscrito = selectedEvent != null && _eventosInscritos.contains(selectedEvent.id);
    final int participantes = selectedEvent != null ? (_participantesContagem[selectedEvent.id] ?? 0) : 0;
    final String categoriaSelected = selectedEvent != null ? _detectarCategoria(selectedEvent) : 'Geral';
    final String distanciaSelected = selectedEvent != null
        ? _distanciasMock[selectedEvent.id % _distanciasMock.length]
        : '1.5 km';

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
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.socialjoin.app',
              ),
              MarkerLayer(
                markers: _eventosFiltrados.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Evento event = entry.value;
                  final bool isSelected = index == _selectedEventIndex;
                  final LatLng coord = _coordenadasEventos[event.id] ?? _locaisReferencia[0];

                  return Marker(
                    width: isSelected ? 80 : 54,
                    height: isSelected ? 84 : 60,
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
                                  blurRadius: isSelected ? 12 : 4,
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
                                  event.titulo.length > 10
                                      ? '${event.titulo.substring(0, 8)}...'
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
                            size: isSelected ? 26 : 18,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Categorias Chips no topo
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categorias.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFEA3F74),
                      elevation: 3,
                      shadowColor: Colors.black12,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFEA3F74) : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = cat;
                          _aplicarFiltroCategoria();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Botões de Zoom e Recenter na lateral direita
          Positioned(
            right: 16,
            top: 74,
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
                  elevation: 4,
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
                  elevation: 4,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'recenter',
                  onPressed: () => _recenterToEvent(_selectedEventIndex),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEA3F74),
                  elevation: 4,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'refresh_map',
                  onPressed: _carregarEventos,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF64748B),
                  elevation: 4,
                  child: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),

          // Card Flutuante Inferior com o Evento Selecionado
          if (selectedEvent != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
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
                      // Header do Card: Categoria, Distância e Navegação
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
                              categoriaSelected,
                              style: const TextStyle(
                                color: Color(0xFFEA3F74),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.near_me, size: 14, color: Color(0xFFEA3F74)),
                              const SizedBox(width: 4),
                              Text(
                                distanciaSelected,
                                style: const TextStyle(
                                  color: Color(0xFFEA3F74),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Setas para alternar eventos
                              GestureDetector(
                                onTap: () {
                                  if (_selectedEventIndex > 0) {
                                    _recenterToEvent(_selectedEventIndex - 1);
                                  }
                                },
                                child: Icon(Icons.chevron_left_rounded,
                                    color: _selectedEventIndex > 0 ? const Color(0xFF0F172A) : Colors.grey.shade300,
                                    size: 22),
                              ),
                              Text(
                                '${_selectedEventIndex + 1}/${_eventosFiltrados.length}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_selectedEventIndex < _eventosFiltrados.length - 1) {
                                    _recenterToEvent(_selectedEventIndex + 1);
                                  }
                                },
                                child: Icon(Icons.chevron_right_rounded,
                                    color: _selectedEventIndex < _eventosFiltrados.length - 1
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade300,
                                    size: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Título do Evento
                      Text(
                        selectedEvent.titulo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Local
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

                      // Data, Horário e Participantes
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '${selectedEvent.dataFormatada} • ${selectedEvent.horarioFormatado}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.people_outline_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '$participantes inscritos',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Ações: Como Chegar e Participar
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _snack('Traçando rota para ${selectedEvent.localEvento}...',
                                    cor: const Color(0xFF0F172A));
                              },
                              icon: const Icon(Icons.directions, size: 16),
                              label: const Text('Como Chegar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F172A),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: isInscrito
                                ? OutlinedButton.icon(
                                    onPressed: () => _toggleParticipacao(selectedEvent),
                                    icon: const Icon(Icons.check_circle_rounded,
                                        size: 16, color: Color(0xFF10B981)),
                                    label: const Text('Inscrito (Sair)'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF10B981),
                                      side: const BorderSide(color: Color(0xFF10B981)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => _toggleParticipacao(selectedEvent),
                                    icon: const Icon(Icons.event_available_rounded, size: 16),
                                    label: const Text('Participar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEA3F74),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_eventosReais.isNotEmpty && _eventosFiltrados.isEmpty)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFEA3F74)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Nenhum evento encontrado nesta categoria.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Todos';
                            _aplicarFiltroCategoria();
                          });
                        },
                        child: const Text('Ver Todos'),
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
