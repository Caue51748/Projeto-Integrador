import 'package:flutter/material.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final List<Map<String, dynamic>> _communities = [
    {
      'name': 'Desenvolvedores Flutter',
      'category': 'Tecnologia',
      'members': 142,
      'description': 'Comunidade focada em compartilhar código, dicas, tirar dúvidas sobre Dart e Flutter.',
      'icon': Icons.code,
      'color': const Color(0xFF2563EB),
      'joined': true,
    },
    {
      'name': 'Design UX/UI & Prototipagem',
      'category': 'Design',
      'members': 89,
      'description': 'Espaço dedicado a designers para discutir interfaces, componentes e acessibilidade.',
      'icon': Icons.palette,
      'color': const Color(0xFF8B5CF6),
      'joined': false,
    },
    {
      'name': 'Games & eSports',
      'category': 'Entretenimento',
      'members': 210,
      'description': 'Grupo para organizar partidas, campeonatos de Valorant, League of Legends e montar squads.',
      'icon': Icons.sports_esports,
      'color': const Color(0xFFEC4899),
      'joined': true,
    },
    {
      'name': 'Projetos Integradores & TCC',
      'category': 'Acadêmico',
      'members': 67,
      'description': 'Ajuda mútua para documentação, diagramas de classe, banco de dados e prazos acadêmicos.',
      'icon': Icons.school,
      'color': const Color(0xFF10B981),
      'joined': false,
    },
  ];

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.groups, color: Color(0xFFEA3F74)),
            SizedBox(width: 10),
            Text('Criar Comunidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Comunidade',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.group_add),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição e Objetivos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.info_outline),
              ),
            ),
          ],
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
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _communities.insert(0, {
                    'name': nameController.text.trim(),
                    'category': 'Geral',
                    'members': 1,
                    'description': descController.text.trim().isEmpty ? 'Sem descrição' : descController.text.trim(),
                    'icon': Icons.stars,
                    'color': const Color(0xFFEA3F74),
                    'joined': true,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comunidade criada com sucesso!'),
                    backgroundColor: Color(0xFFEA3F74),
                  ),
                );
              }
            },
            child: const Text('Criar'),
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
                        colors: [Color(0xFF1E2433), Color(0xFFEA3F74)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA3F74).withOpacity(0.2),
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
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.hub, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comunidades',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Conecte-se com grupos com os mesmos interesses',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showCreateCommunityDialog,
                          icon: const Icon(Icons.group_add, size: 18),
                          label: const Text('Nova Comunidade', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E2433),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Todas as Comunidades (${_communities.length})',
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
                  final item = _communities[index];
                  final bool isJoined = item['joined'];

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
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item['icon'], color: item['color'], size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item['category']} • ${item['members']} membros',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['description'],
                            style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: isJoined
                                ? OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        item['joined'] = false;
                                        item['members'] -= 1;
                                      });
                                    },
                                    icon: const Icon(Icons.check, size: 18, color: Color(0xFF10B981)),
                                    label: const Text('Membro (Sair)', style: TextStyle(color: Color(0xFF475569))),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        item['joined'] = true;
                                        item['members'] += 1;
                                      });
                                    },
                                    icon: const Icon(Icons.person_add, size: 18),
                                    label: const Text('Participar da Comunidade'),
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
                    ),
                  );
                },
                childCount: _communities.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}