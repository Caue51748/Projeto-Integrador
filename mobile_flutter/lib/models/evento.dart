class Evento {
  final int id;
  final String titulo;
  final String? descricao;
  final String dataEvento;
  final String horarioInicio;
  final String horarioFim;
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
  final double? latitude;
  final double? longitude;

  const Evento({
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
    this.latitude,
    this.longitude,
  });

  static int? _intOrNull(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    if (v is Map) return _intOrNull(v['id'] ?? v['idUsuario']);
    return null;
  }

  static double? _doubleOrNull(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  static String _date(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    if (val is List && val.length >= 3) {
      return '${val[0].toString().padLeft(4, '0')}-${val[1].toString().padLeft(2, '0')}-${val[2].toString().padLeft(2, '0')}';
    }
    if (val is Map) {
      final ano = val['year'] ?? val['ano'] ?? '';
      final mes = val['monthValue'] ?? val['month'] ?? val['mes'] ?? '';
      final dia = val['dayOfMonth'] ?? val['day'] ?? val['dia'] ?? '';
      return '$ano-${mes.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
    }
    return val.toString();
  }

  static String _time(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    if (val is List && val.length >= 2) {
      return '${val[0].toString().padLeft(2, '0')}:${val[1].toString().padLeft(2, '0')}:${val.length > 2 ? val[2].toString().padLeft(2, '0') : '00'}';
    }
    if (val is Map) {
      final hora = val['hour'] ?? val['hora'] ?? 0;
      final minuto = val['minute'] ?? val['minuto'] ?? 0;
      final segundo = val['second'] ?? val['segundo'] ?? 0;
      return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}:${segundo.toString().padLeft(2, '0')}';
    }
    return val.toString();
  }

  static bool _bool(dynamic val, [bool padrao = false]) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) return val.toLowerCase() == 'true' || val == '1';
    return padrao;
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    final loc = json['localizacao'] is Map ? json['localizacao'] as Map :
        (json['coordenadas'] is Map ? json['coordenadas'] as Map :
        (json['location'] is Map ? json['location'] as Map : const {}));
    final lat = _doubleOrNull(json['latitude'] ?? json['lat'] ?? loc['latitude'] ?? loc['lat']);
    final lng = _doubleOrNull(json['longitude'] ?? json['lng'] ?? json['lon'] ?? loc['longitude'] ?? loc['lng'] ?? loc['lon']);
    final coordsValidas = lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    return Evento(
      id: _intOrNull(json['id'] ?? json['idEvento'] ?? json['id_evento']) ?? 0,
      titulo: (json['titulo'] ?? 'Evento sem título').toString(),
      descricao: json['descricao']?.toString(),
      dataEvento: _date(json['dataEvento'] ?? json['data_evento'] ?? json['data']),
      horarioInicio: _time(json['horarioInicio'] ?? json['horario_inicio'] ?? json['inicio']),
      horarioFim: _time(json['horarioFim'] ?? json['horario_fim'] ?? json['fim']),
      localEvento: (json['localEvento'] ?? json['local_evento'] ?? json['local'] ?? 'Local a confirmar').toString(),
      comunidadeId: _intOrNull(json['comunidadeId'] ?? json['comunidade_id']),
      criadorId: _intOrNull(json['criadorId'] ?? json['criador_id']),
      limiteParticipantes: _intOrNull(json['limiteParticipantes'] ?? json['limite_participantes']),
      status: (json['status'] ?? 'AGENDADO').toString(),
      exigeCheckin: _bool(json['exigeCheckin'] ?? json['exige_checkin']),
      encerramentoInscricoes: json['encerramentoInscricoes']?.toString(),
      situacaoTemporal: json['situacaoTemporal']?.toString(),
      publico: json['publico'] == null ? (json['comunidadeId'] ?? json['comunidade_id']) == null : _bool(json['publico']),
      categoria: json['categoria']?.toString(),
      imagemCapa: (json['imagemCapa'] ?? json['capa'])?.toString(),
      latitude: coordsValidas ? lat : null,
      longitude: coordsValidas ? lng : null,
    );
  }

  Map<String, dynamic> toJson() => {
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
    // Só enviar esses campos se o backend realmente os aceitar.
  };

  bool get ehPublico {
    if (status.toUpperCase() == 'CANCELADO') return false;
    if (publico != null) return publico!;
    return comunidadeId == null;
  }
  String get situacaoCalculada => situacaoTemporal ?? status;
  String get dataFormatada {
    try {
      final partes = dataEvento.split('-');
      if (partes.length != 3) return dataEvento;
      final m = int.parse(partes[1]);
      const meses = ['', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
      if (m < 1 || m > 12) return dataEvento;
      return '${partes[2]} de ${meses[m]} de ${partes[0]}';
    } catch (_) { return dataEvento; }
  }
  String get horarioFormatado => horarioInicio.length >= 5 ? horarioInicio.substring(0, 5) : horarioInicio;
}
