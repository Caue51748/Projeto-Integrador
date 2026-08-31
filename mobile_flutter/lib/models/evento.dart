class Evento {
  final int id;
  final String titulo;
  final String? descricao;
  final String dataEvento; // yyyy-MM-dd
  final String horarioInicio; // HH:mm:ss
  final String horarioFim; // HH:mm:ss
  final String localEvento;
  final int? comunidadeId;
  final int? criadorId;
  final int? limiteParticipantes;
  final String status;
  final bool exigeCheckin;
  final String? encerramentoInscricoes;
  final String? situacaoTemporal;
  final bool? publico;
  final String? categoria;
  final String? imagemCapa;

  Evento({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.dataEvento,
    required this.horarioInicio,
    required this.horarioFim,
    required this.localEvento,
    this.comunidadeId,
    this.criadorId,
    this.limiteParticipantes,
    this.status = 'AGENDADO',
    this.exigeCheckin = false,
    this.encerramentoInscricoes,
    this.situacaoTemporal,
    this.publico,
    this.categoria,
    this.imagemCapa,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    final parsedId = (json['id'] ?? json['idEvento'] ?? json['id_evento'] as num?)?.toInt() ?? 0;
    return Evento(
      id: parsedId,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      dataEvento: json['dataEvento'] ?? '',
      horarioInicio: json['horarioInicio'] ?? '',
      horarioFim: json['horarioFim'] ?? '',
      localEvento: json['localEvento'] ?? '',
      comunidadeId: (json['comunidadeId'] ?? json['comunidade_id'] as num?)?.toInt(),
      criadorId: (json['criadorId'] ?? json['criador_id'] as num?)?.toInt(),
      limiteParticipantes: (json['limiteParticipantes'] as num?)?.toInt(),
      status: json['status'] ?? 'AGENDADO',
      exigeCheckin: json['exigeCheckin'] ?? false,
      encerramentoInscricoes: json['encerramentoInscricoes'],
      situacaoTemporal: json['situacaoTemporal'],
      publico: json['publico'] ?? json['ehPublico'] ?? (json['comunidadeId'] == null),
      categoria: json['categoria'] ?? json['nomeCategoria'],
      imagemCapa: json['imagemCapa'] ?? json['capa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataEvento': dataEvento,
      'horarioInicio': horarioInicio,
      'horarioFim': horarioFim,
      'localEvento': localEvento,
      if (comunidadeId != null) 'comunidadeId': comunidadeId,
      if (criadorId != null) 'criadorId': criadorId,
      if (limiteParticipantes != null) 'limiteParticipantes': limiteParticipantes,
      'status': status,
      'exigeCheckin': exigeCheckin,
      if (publico != null) 'publico': publico,
      if (categoria != null) 'categoria': categoria,
      if (imagemCapa != null) 'imagemCapa': imagemCapa,
    };
  }

  /// Retorna se o evento é estritamente público (não associado a comunidade privada e não cancelado)
  bool get ehPublico {
    if (status == 'CANCELADO') return false;
    if (publico != null) return publico!;
    return comunidadeId == null;
  }

  /// Retorna a situação real do evento baseada em data/hora local
  String get situacaoCalculada {
    final sit = situacaoTemporal ?? status;
    return sit;
  }

  /// Formata a data para exibição: "15 de ago. de 2026"
  String get dataFormatada {
    try {
      final parts = dataEvento.split('-');
      if (parts.length != 3) return dataEvento;
      final ano = parts[0];
      final mes = int.parse(parts[1]);
      final dia = parts[2];
      const meses = [
        '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
        'jul', 'ago', 'set', 'out', 'nov', 'dez'
      ];
      return '$dia de ${meses[mes]} de $ano';
    } catch (_) {
      return dataEvento;
    }
  }

  /// Retorna apenas HH:mm
  String get horarioFormatado {
    if (horarioInicio.length >= 5) {
      return horarioInicio.substring(0, 5);
    }
    return horarioInicio;
  }
}
