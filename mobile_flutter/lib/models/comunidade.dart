class MembroComunidade {
  final int? idUsuario;
  final String nome;
  final String? username;
  final String? role;
  final bool isPremium;

  MembroComunidade({
    this.idUsuario,
    required this.nome,
    this.username,
    this.role,
    this.isPremium = false,
  });

  factory MembroComunidade.fromJson(Map<String, dynamic> json) {
    final roleVal = json['role']?.toString();
    final premiumVal = json['premium'] == true ||
        (roleVal != null && roleVal.toLowerCase().contains('premium'));
    return MembroComunidade(
      idUsuario: json['idUsuario'] ?? json['id_usuario'],
      nome: json['nome'] ?? '',
      username: json['username'],
      role: roleVal,
      isPremium: premiumVal,
    );
  }
}

class Comunidade {
  final int id;
  final String nome;
  final String? descricao;
  final MembroComunidade? criador;
  final List<MembroComunidade> membros;

  Comunidade({
    required this.id,
    required this.nome,
    this.descricao,
    this.criador,
    this.membros = const [],
  });

  int get totalMembros => membros.length;
  bool get isPremium => criador?.isPremium ?? false;

  bool isMembro(int? idUsuario) {
    if (idUsuario == null) return false;
    return membros.any((m) => m.idUsuario == idUsuario);
  }

  factory Comunidade.fromJson(Map<String, dynamic> json) {
    final membrosJson = json['membros'] as List<dynamic>? ?? [];
    final membros = membrosJson
        .map((m) => MembroComunidade.fromJson(m as Map<String, dynamic>))
        .toList();

    MembroComunidade? criador;
    if (json['criador'] != null) {
      criador = MembroComunidade.fromJson(
          json['criador'] as Map<String, dynamic>);
    }

    return Comunidade(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      criador: criador,
      membros: membros,
    );
  }
}
