import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../services/location_service.dart';

/// Descoberta de eventos na Home. Sem coordenadas fictícias.
/// Distâncias só são exibidas após autorização e obtenção real do GPS.
class EventosHomePage extends StatefulWidget {
  final void Function(int? eventoId) onAbrirMapa;
  final VoidCallback onVerTodos;
  final VoidCallback onCriarEvento;

  const EventosHomePage({
    super.key,
    required this.onAbrirMapa,
    required this.onVerTodos,
    required this.onCriarEvento,
  });

  @override
  State<EventosHomePage> createState() => _EventosHomePageState();
}

class _EventosHomePageState extends State<EventosHomePage> {
  static const _rosa = Color(0xFFEA3F74);
  static const _texto = Color(0xFF242632);
  static const _cinza = Color(0xFF737987);
  static const _raioKm = 50.0;
  final _eventosService = EventoService();
  final _localizacao = LocationService();
  final _busca = TextEditingController();

  List<Evento> _eventos = [];
  Position? _posicao;
  bool _carregando = true;
  bool _soProximos = true;
  String? _erro;
  String? _avisoGPS;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  bool _temCoordenadas(Evento ev) {
    final lat = ev.latitude;
    final lng = ev.longitude;
    return lat != null && lng != null &&
        lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180 &&
        !(lat == 0 && lng == 0);
  }

  double? _distancia(Evento ev) {
    final p = _posicao;
    if (p == null || !_temCoordenadas(ev)) return null;
    return Geolocator.distanceBetween(
      p.latitude, p.longitude, ev.latitude!, ev.longitude!,
    ) / 1000;
  }

  bool _estaAgendado(Evento e) {
    final status = e.status.toUpperCase();
    if (status == 'CANCELADO' || status == 'ENCERRADO' ||
        status == 'FINALIZADO') return false;
    final dia = DateTime.tryParse(e.dataEvento);
    if (dia == null) return true;
    final hoje = DateTime.now();
    final atual = DateTime(hoje.year, hoje.month, hoje.day);
    return !dia.isBefore(atual);
  }

  Future<void> _buscarDados() async {
    if (mounted) setState(() { _carregando = true; _erro = null; });
    try {
      final eventos = await _eventosService.listarEventos();
      if (!mounted) return;
      // Exibe os eventos assim que a API responde, sem esperar o GPS.
      setState(() { _eventos = eventos; _carregando = false; });
      Position? posicao;
      String? aviso;
      try {
        var permissao = await _localizacao.verificarPermissao();
        if (permissao == LocationPermission.denied) {
          permissao = await _localizacao.solicitarPermissao();
        }
        if (permissao == LocationPermission.always ||
            permissao == LocationPermission.whileInUse) {
          posicao = await _localizacao.obterPosicaoAtual();
          if (posicao == null) aviso = 'Localização indisponível. Explore todos os eventos.';
        } else {
          aviso = 'Permita a localização para descobrir eventos próximos.';
        }
      } catch (_) {
        aviso = 'GPS indisponível. Você ainda pode explorar os eventos.';
      }
      if (!mounted) return;
      setState(() {
        _posicao = posicao;
        _avisoGPS = aviso;
        _soProximos = posicao != null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Não foi possível carregar os eventos. Confira a conexão com a API.';
      });
    }
  }

  List<Evento> get _resultados {
    final termo = _busca.text.trim().toLowerCase();
    final lista = _eventos.where((e) {
      if (!_estaAgendado(e)) return false;
      if (termo.isNotEmpty &&
          !('${e.titulo} ${e.localEvento} ${e.descricao ?? ''} ${e.categoria ?? ''}'
              .toLowerCase().contains(termo))) return false;
      if (_soProximos && _posicao != null) {
        final d = _distancia(e);
        if (d == null || d > _raioKm) return false;
      }
      return true;
    }).toList();
    lista.sort((a, b) {
      final ad = _distancia(a);
      final bd = _distancia(b);
      if (_posicao != null) {
        if (ad != null && bd != null) {
          final diff = ad.compareTo(bd);
          if (diff != 0) return diff;
        } else if (ad != null) {
          return -1;
        } else if (bd != null) {
          return 1;
        }
      }
      return a.dataEvento.compareTo(b.dataEvento);
    });
    return lista;
  }

  IconData _icone(Evento e) {
    final c = (e.categoria ?? '').toLowerCase();
    if (c.contains('tecnol')) return Icons.code_rounded;
    if (c.contains('game')) return Icons.sports_esports_rounded;
    if (c.contains('design') || c.contains('arte')) return Icons.palette_outlined;
    if (c.contains('acad') || c.contains('educ')) return Icons.school_outlined;
    if (c.contains('esport')) return Icons.sports_basketball_rounded;
    return Icons.local_activity_outlined;
  }

  Widget _chip(String titulo, bool ativo, VoidCallback aoClicar) =>
      ChoiceChip(
        label: Text(titulo), selected: ativo, onSelected: (_) => aoClicar(),
        showCheckmark: false,
        selectedColor: const Color(0xFFFFE7F0),
        backgroundColor: Colors.white,
        side: BorderSide(color: ativo ? _rosa : const Color(0xFFE5E7EC)),
        labelStyle: TextStyle(color: ativo ? _rosa : _texto,
          fontWeight: FontWeight.w700, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _cartao(Evento e) {
    final distancia = _distancia(e);
    final dia = e.dataFormatada;
    final temMapa = _temCoordenadas(e);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (temMapa) { widget.onAbrirMapa(e.id); }
            else { widget.onVerTodos(); }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0F0F3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 58, height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAF2),
                  borderRadius: BorderRadius.circular(15)),
                child: Icon(_icone(e), size: 29, color: _rosa)),
              const SizedBox(width: 13),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(e.categoria?.isNotEmpty == true
                        ? e.categoria!.toUpperCase() : 'EVENTO',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10,
                        letterSpacing: 0.8, fontWeight: FontWeight.w800, color: _rosa))),
                    if (distancia != null) Text('${distancia.toStringAsFixed(1)} km',
                      style: const TextStyle(color: _rosa, fontSize: 11,
                        fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 5),
                  Text(e.titulo, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, height: 1.2,
                      fontWeight: FontWeight.w800, color: _texto)),
                  const SizedBox(height: 7),
                  Row(children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: _cinza),
                    const SizedBox(width: 4),
                    Expanded(child: Text('$dia · ${e.horarioFormatado}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _cinza, fontSize: 11))),
                  ]),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: _cinza),
                    const SizedBox(width: 3),
                    Expanded(child: Text(e.localEvento,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _cinza, fontSize: 11))),
                    Icon(temMapa ? Icons.arrow_outward_rounded : Icons.chevron_right_rounded,
                      size: 17, color: _rosa),
                  ]),
                ],
              )),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;
    return RefreshIndicator(
      color: _rosa, onRefresh: _buscarDados,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEA3F74), Color(0xFFE96891)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DESCUBRA POR PERTO', style: TextStyle(color: Color(0xFFFFDDE8),
                letterSpacing: 1.1, fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Encontre seu próximo evento',
                style: TextStyle(color: Colors.white, fontSize: 23,
                  fontWeight: FontWeight.w800, height: 1.12)),
              const SizedBox(height: 10),
              Row(children: [
                Icon(_posicao != null ? Icons.my_location_rounded : Icons.location_off_outlined,
                  color: Colors.white, size: 15),
                const SizedBox(width: 7),
                Expanded(child: Text(_posicao != null
                    ? 'Eventos a até ${_raioKm.toStringAsFixed(0)} km de você'
                    : 'Explore eventos e permita a localização',
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
              ]),
              const SizedBox(height: 15),
              SizedBox(width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onCriarEvento,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: _rosa,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                  icon: const Icon(Icons.add_rounded, size: 21),
                  label: const Text('Criar evento', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 9),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => widget.onAbrirMapa(null),
                  style: OutlinedButton.styleFrom(foregroundColor: _rosa,
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Explorar mapa'))),
                const SizedBox(width: 8),
                IconButton.filledTonal(onPressed: _buscarDados,
                  tooltip: 'Atualizar localização',
                  style: IconButton.styleFrom(backgroundColor: const Color(0x33FFFFFF),
                    foregroundColor: Colors.white),
                  icon: const Icon(Icons.my_location_outlined)),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _busca, onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Pesquisar eventos, locais e categorias',
              hintStyle: const TextStyle(fontSize: 13, color: _cinza),
              prefixIcon: const Icon(Icons.search_rounded, color: _rosa),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          if (_posicao == null && _avisoGPS != null)
            Padding(padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: _cinza, size: 15),
                const SizedBox(width: 8),
                Expanded(child: Text(_avisoGPS!,
                  style: const TextStyle(color: _cinza, fontSize: 12))),
              ])),
          Row(children: [
            Expanded(child: Text('Eventos em destaque',
              style: const TextStyle(fontSize: 18, color: _texto,
                fontWeight: FontWeight.w800))),
            TextButton(onPressed: widget.onVerTodos,
              child: const Text('Ver todos', style: TextStyle(color: _rosa))),
          ]),
          Wrap(spacing: 8, children: [
            if (_posicao != null) _chip('Perto de mim', _soProximos,
              () => setState(() => _soProximos = true)),
            _chip('Todos', !_soProximos || _posicao == null,
              () => setState(() => _soProximos = false)),
          ]),
          const SizedBox(height: 8),
          if (_carregando)
            const Padding(padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator(color: _rosa)))
          else if (_erro != null)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(children: [
                const Icon(Icons.wifi_off_rounded, color: _cinza, size: 30),
                const SizedBox(height: 8),
                Text(_erro!, textAlign: TextAlign.center),
                TextButton(onPressed: _buscarDados, child: const Text('Tentar novamente')),
              ]))
          else if (resultados.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(children: [
                const Icon(Icons.event_busy_outlined, size: 40, color: _cinza),
                const SizedBox(height: 8),
                Text(_soProximos ? 'Nenhum evento a até 50 km no momento.'
                    : 'Nenhum evento encontrado.', textAlign: TextAlign.center,
                    style: const TextStyle(color: _texto, fontWeight: FontWeight.w700)),
                if (_soProximos) TextButton(
                  onPressed: () => setState(() => _soProximos = false),
                  child: const Text('Ver eventos de todas as regiões')),
              ]))
          else ...resultados.take(30).map(_cartao),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
