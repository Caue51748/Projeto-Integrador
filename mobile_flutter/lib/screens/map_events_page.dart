import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapEventsPage extends StatefulWidget {
  const MapEventsPage({super.key});

  @override
  State<MapEventsPage> createState() => _MapEventsPageState();
}

class _MapEventsPageState extends State<MapEventsPage> {
  late final MapController _mapController;
  int _selectedEventIndex = 0;
  String _selectedCategory = 'Todos';

  // Real geographic locations for events worldwide
  final List<Map<String, dynamic>> _mapEvents = [
    {
      'id': 1,
      'title': 'Hackathon Resenha Tech 2026',
      'category': 'Tecnologia',
      'location': 'Auditório Bloco A - Campus Paulista',
      'address': 'Av. Paulista, 1100 - São Paulo, SP',
      'distance': '1.2 km',
      'time': '15 Ago • 09:00',
      'attendees': 48,
      'coords': const LatLng(-23.5615, -46.6560), // Av Paulista
    },
    {
      'id': 2,
      'title': 'Encontro UX/UI & Mobile Design',
      'category': 'Design',
      'location': 'Hub de Inovação Faria Lima',
      'address': 'Av. Brig. Faria Lima, 3477 - São Paulo, SP',
      'distance': '3.4 km',
      'time': '20 Ago • 19:30',
      'attendees': 32,
      'coords': const LatLng(-23.5855, -46.6815), // Faria Lima
    },
    {
      'id': 3,
      'title': 'Torneio de E-Sports Resenha',
      'category': 'Games',
      'location': 'Arena Gamer Ibirapuera',
      'address': 'Parque Ibirapuera - Portão 3 - São Paulo, SP',
      'distance': '4.1 km',
      'time': '28 Ago • 14:00',
      'attendees': 64,
      'coords': const LatLng(-23.5874, -46.6576), // Ibirapuera
    },
    {
      'id': 4,
      'title': 'Feira Global de Inovação',
      'category': 'Acadêmico',
      'location': 'Expo Center Norte',
      'address': 'Rua José Bernardo Pinto, 333 - São Paulo, SP',
      'distance': '7.8 km',
      'time': '05 Set • 10:00',
      'attendees': 120,
      'coords': const LatLng(-23.5165, -46.6186), // Expo Center
    },
    {
      'id': 5,
      'title': 'Meetup Devs Rio de Janeiro',
      'category': 'Tecnologia',
      'location': 'Porto Maravilha Tech Hub',
      'address': 'Praça Mauá, 1 - Rio de Janeiro, RJ',
      'distance': '350 km',
      'time': '12 Set • 15:00',
      'attendees': 95,
      'coords': const LatLng(-22.8961, -43.1802), // Rio
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _recenterToEvent(int index) {
    setState(() {
      _selectedEventIndex = index;
    });
    final event = _mapEvents[index];
    _mapController.move(event['coords'] as LatLng, 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvent = _mapEvents[_selectedEventIndex];

    final filteredEvents = _selectedCategory == 'Todos'
        ? _mapEvents
        : _mapEvents.where((e) => e['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // REAL WORLDWIDE MAP LAYER (OpenStreetMap tiles)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-23.5615, -46.6560), // Centered at São Paulo
              initialZoom: 13.0,
              minZoom: 2.0, // Can zoom out to see the entire Earth!
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap Tile Layer (Free & Worldwide)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.resenhaoumorte.app',
              ),

              // Marker Layer for Events
              MarkerLayer(
                markers: filteredEvents.map((event) {
                  final int index = _mapEvents.indexOf(event);
                  final bool isSelected = index == _selectedEventIndex;

                  return Marker(
                    width: isSelected ? 60 : 46,
                    height: isSelected ? 70 : 54,
                    point: event['coords'] as LatLng,
                    child: GestureDetector(
                      onTap: () {
                        _recenterToEvent(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
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
                                    color: isSelected ? const Color(0xFFEA3F74).withOpacity(0.45) : Colors.black38,
                                    blurRadius: isSelected ? 10 : 4,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.location_on : Icons.event,
                                    color: Colors.white,
                                    size: isSelected ? 14 : 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event['category'],
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
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Header Filter Chips
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Tecnologia', 'Design', 'Games', 'Acadêmico'].map((cat) {
                  final bool isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFEA3F74),
                      elevation: 3,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Zoom & Recenter Controls
          Positioned(
            right: 16,
            top: 80,
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
                  onPressed: () {
                    _recenterToEvent(_selectedEventIndex);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEA3F74),
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // Bottom Card - Selected Event Information Overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              elevation: 10,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                            selectedEvent['category'],
                            style: const TextStyle(
                              color: Color(0xFFEA3F74),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.near_me, size: 14, color: Color(0xFFEA3F74)),
                            const SizedBox(width: 4),
                            Text(
                              selectedEvent['distance'],
                              style: const TextStyle(
                                color: Color(0xFFEA3F74),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedEvent['title'],
                      style: const TextStyle(
                        fontSize: 18,
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
                            selectedEvent['location'],
                            style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        selectedEvent['address'],
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Navegando até ${selectedEvent['location']} no mapa!'),
                                  backgroundColor: const Color(0xFFEA3F74),
                                ),
                              );
                            },
                            icon: const Icon(Icons.directions, size: 18),
                            label: const Text('Como Chegar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEA3F74),
                              side: const BorderSide(color: Color(0xFFEA3F74)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Presença confirmada no evento!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Participar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA3F74),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
