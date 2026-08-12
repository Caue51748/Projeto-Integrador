import 'package:flutter/material.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final List<Map<String, String>> _events = [
    {
      'title': 'Hackathon Resenha Tech 2026',
      'date': '15 de Agosto, 2026 • 09:00',
      'location': 'Auditório Bloco A - Campus Central',
      'description': 'Maratona de programação de 24 horas com prêmios para os melhores projetos de inovação.',
      'category': 'Tecnologia',
      'attendees': '48 participantes'
    },
    {
      'title': 'Encontro de Design UX/UI & Mobile',
      'date': '20 de Agosto, 2026 • 19:30',
      'location': 'Online (Google Meet)',
      'description': 'Workshop interativo sobre design sistemas, micro-interações e prototipagem em Flutter.',
      'category': 'Design',
      'attendees': '32 participantes'
    },
    {
      'title': 'Torneio de E-Sports Resenha',
      'date': '28 de Agosto, 2026 • 14:00',
      'location': 'Arena Gamer / Discord',
      'description': 'Campeonato interno com prêmios de RP e brindes exclusivos.',
      'category': 'Games',
      'attendees': '64 participantes'
    },
  ];

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.event_available, color: Color(0xFFEA3F74)),
            SizedBox(width: 10),
            Text('Criar Novo Evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título do Evento',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Data e Hora (ex: 30 de Ago, 18:00)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Localização',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição do Evento',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA3F74),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  _events.insert(0, {
                    'title': titleController.text.trim(),
                    'date': dateController.text.trim().isEmpty ? 'Em breve' : dateController.text.trim(),
                    'location': locationController.text.trim().isEmpty ? 'Local a definir' : locationController.text.trim(),
                    'description': descriptionController.text.trim().isEmpty ? 'Sem descrição' : descriptionController.text.trim(),
                    'category': 'Geral',
                    'attendees': '1 participante'
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Evento criado com sucesso!'),
                    backgroundColor: Color(0xFFEA3F74),
                  ),
                );
              }
            },
            child: const Text('Publicar Evento'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEA3F74), Color(0xFFFF5B8C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA3F74).withOpacity(0.25),
                          blurRadius: 15,
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
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Agenda de Eventos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Fique por dentro das resenhas e encontros',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddEventDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Criar Evento', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFEA3F74),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Próximos Eventos (${_events.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = _events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF0F4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFCBD8)),
                                ),
                                child: Text(
                                  event['category']!,
                                  style: const TextStyle(
                                    color: Color(0xFFEA3F74),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.people_outline, size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    event['attendees']!,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event['title']!,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled, size: 16, color: Color(0xFFEA3F74)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  event['date']!,
                                  style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFFEF4444)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  event['location']!,
                                  style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event['description']!,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Presença confirmada no evento ${event['title']}!'),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Confirmar Presença'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEA3F74),
                                side: const BorderSide(color: Color(0xFFEA3F74)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _events.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
