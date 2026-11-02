import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';

/// Mapa de verdade: sem chave Google e sem coordenadas inventadas.
/// Eventos precisam receber latitude/longitude válidas da API.
class MapEventsPage extends StatefulWidget {
  final int? eventoInicialId;
  const MapEventsPage({super.key, this.eventoInicialId});

  @override
  State<MapEventsPage> createState() => _MapEventsPageState();
}

class _MapEventsPageState extends State<MapEventsPage> {
  final MapController _map = MapController();
  final EventoService _service = EventoService();
  List<Evento> _todos = [];
  Evento? _selecionado;
  Position? _posicao;
  bool _carregando = true;
  bool _mapPronto = false;
  String? _erro;
  String _categoria = 'Todos';
  Timer? _atualizacao;

  static const Color rosa = Color(0xFFEA3F74);
  static const LatLng centroInicial = LatLng(-22.5646, -47.4017);

  Iterable<Evento> get _comCoordenadas => _todos.where((e) => e.latitude != null && e.longitude != null);
  List<Evento> get _filtrados => _comCoordenadas.where((e) => _categoria == 'Todos' || (e.categoria ?? 'Outros') == _categoria).toList();
  List<String> get _categorias {
    final nomes = _todos.map((e) => e.categoria ?? 'Outros').toSet().toList()..sort();
    return ['Todos', ...nomes];
  }

  @override
  void initState() {
    super.initState();
    _carregar();
    // Atualiza eventos enquanto esta tela estiver aberta, sem alegar WebSocket.
    _atualizacao = Timer.periodic(const Duration(seconds: 60), (_) => _carregar(silencioso: true));
  }

  @override
  void dispose() {
    _atualizacao?.cancel();
    _map.dispose();
    super.dispose();
  }

  void _focar(LatLng ponto, [double zoom = 14]) {
    if (_mapPronto) _map.move(ponto, zoom);
  }

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso && mounted) setState(() { _carregando = true; _erro = null; });
    try {
      final lista = await _service.listarEventos();
      if (!mounted) return;
      final antigoId = _selecionado?.id ?? widget.eventoInicialId;
      Evento? escolhido;
      for (final e in lista) {
        if (e.id == antigoId) { escolhido = e; break; }
      }
      if (escolhido == null) {
        for (final e in lista) {
          if (e.latitude != null && e.longitude != null) { escolhido = e; break; }
        }
      }
      setState(() {
        _todos = lista;
        _selecionado = escolhido;
        _carregando = false;
        _erro = null;
      });
      if (escolhido?.latitude != null && escolhido?.longitude != null) {
        _focar(LatLng(escolhido!.latitude!, escolhido.longitude!), 13.5);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = 'Não foi possível carregar eventos da API: $e'; _carregando = false; });
    }
  }

  Future<void> _localizar() async {
    try {
      final perm = await LocationService().solicitarPermissao();
      if (perm != LocationPermission.whileInUse && perm != LocationPermission.always) {
        _mensagem('Permita o acesso à localização nas configurações do dispositivo.');
        return;
      }
      final p = await LocationService().obterPosicaoAtual();
      if (!mounted) return;
      if (p == null) { _mensagem('Não foi possível obter sua localização.'); return; }
      setState(() => _posicao = p);
      _focar(LatLng(p.latitude, p.longitude), 14);
    } catch (_) { _mensagem('Localização indisponível neste dispositivo.'); }
  }

  void _mensagem(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  IconData _icone(Evento e) {
    switch ((e.categoria ?? '').toLowerCase()) {
      case 'tecnologia': return Icons.computer_rounded;
      case 'games': return Icons.sports_esports_rounded;
      case 'design': return Icons.palette_rounded;
      case 'acadêmico': return Icons.school_rounded;
      case 'comunidade': return Icons.groups_rounded;
      default: return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final marcados = _filtrados;
    final temLocalizacao = _todos.any((e) => e.latitude != null && e.longitude != null);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: centroInicial,
            initialZoom: 12.5,
            minZoom: 3,
            maxZoom: 19,
            onMapReady: () {
              _mapPronto = true;
              final e = _selecionado;
              if (e?.latitude != null && e?.longitude != null) {
                _focar(LatLng(e!.latitude!, e.longitude!), 13.5);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'socialjoin.mobile',
            ),
            MarkerLayer(markers: [
              if (_posicao != null) Marker(
                point: LatLng(_posicao!.latitude, _posicao!.longitude),
                height: 40, width: 40,
                child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 28),
              ),
              ...marcados.map((e) => Marker(
                point: LatLng(e.latitude!, e.longitude!),
                height: 60, width: 60,
                child: GestureDetector(
                  onTap: () => setState(() => _selecionado = e),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selecionado?.id == e.id ? const Color(0xFF7C3AED) : rosa,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Icon(_icone(e), color: Colors.white, size: 28),
                  ),
                ),
              )),
            ]),
            const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
          ],
        ),
        SafeArea(child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Material(
              color: Colors.white,
              elevation: 3,
              borderRadius: BorderRadius.circular(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
                  child: Row(children: [
                    const Icon(Icons.map_outlined, color: rosa),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Eventos no mapa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                    if (_carregando) const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    IconButton(tooltip: 'Recarregar eventos', icon: const Icon(Icons.refresh_rounded), onPressed: _carregar),
                  ]),
                ),
                SizedBox(height: 46, child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  children: _categorias.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _categoria == c,
                      onSelected: (_) => setState(() => _categoria = c),
                    ),
                  )).toList(),
                )),
              ]),
            ),
          ),
        )),
        Positioned(right: 14, top: 152, child: SafeArea(child: FloatingActionButton.small(
          heroTag: 'localizar_socialjoin',
          backgroundColor: Colors.white,
          tooltip: 'Minha localização',
          onPressed: _localizar,
          child: const Icon(Icons.my_location, color: rosa),
        ))),
        if (_erro != null && !_carregando)
          Positioned(top: 210, left: 16, right: 16,
            child: Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_erro!, style: const TextStyle(color: Color(0xFFB91C1C))),
            )),
          ),
        if (!_carregando && _erro == null && !temLocalizacao)
          Positioned(top: 210, left: 16, right: 16,
            child: Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_todos.isEmpty
                  ? 'Nenhum evento cadastrado na API.'
                  : '${_todos.length} evento(s) encontrado(s), mas nenhum possui latitude e longitude na resposta da API. Não é correto inventar posições no mapa.'),
            )),
          ),
        if (_selecionado != null)
          Positioned(left: 12, right: 12, bottom: 14,
            child: SafeArea(top: false,
              child: Card(elevation: 6, child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(_selecionado!.titulo,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    IconButton(tooltip: 'Fechar', icon: const Icon(Icons.close), onPressed: () => setState(() => _selecionado = null)),
                  ]),
                  const SizedBox(height: 4),
                  Text('${_selecionado!.dataFormatada} • ${_selecionado!.horarioFormatado}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(_selecionado!.localEvento, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: FilledButton.icon(
                      onPressed: _selecionado!.latitude == null ? null : () => _focar(
                        LatLng(_selecionado!.latitude!, _selecionado!.longitude!), 15),
                      icon: const Icon(Icons.place_outlined), label: const Text('Ver no mapa'),
                    )),
                    const SizedBox(width: 8),
                    if (AuthService.logado)
                      Expanded(child: OutlinedButton(
                        onPressed: () async {
                          final id = AuthService.idUsuario;
                          if (id == null) return;
                          final ok = await _service.participarEvento(_selecionado!.id, id);
                          _mensagem(ok ? 'Inscrição registrada!' : 'Não foi possível se inscrever.');
                        },
                        child: const Text('Participar'),
                      )),
                  ]),
                ]),
              )),
            ),
          ),
      ]),
    );
  }
}
