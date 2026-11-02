import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _FotoSelecionada {
  final Uint8List bytes;
  final String nome;
  bool enviada = false;
  _FotoSelecionada(this.bytes, this.nome);
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titulo = TextEditingController();
  final _conteudo = TextEditingController();
  final _service = PostService();
  final List<_FotoSelecionada> _fotos = [];
  int? _idPostCriado;
  bool _enviando = false;
  String? _erro;
  static const rosa = Color(0xFFEA3F74);
  static const cinza = Color(0xFF6B7280);

  @override
  void dispose() {
    _titulo.dispose();
    _conteudo.dispose();
    super.dispose();
  }

  Future<void> _escolherImagens() async {
    if (_idPostCriado != null) return;
    try {
      final arquivos = await ImagePicker().pickMultiImage(
        maxWidth: 1600, imageQuality: 82,
      );
      if (arquivos.isEmpty) return;
      final adicionadas = <_FotoSelecionada>[];
      for (final arquivo in arquivos) {
        final nome = arquivo.name.toLowerCase();
        if (!(nome.endsWith('.jpg') || nome.endsWith('.jpeg') ||
            nome.endsWith('.png') || nome.endsWith('.webp'))) {
          if (mounted) setState(() => _erro = 'Use JPG, PNG ou WEBP.');
          return;
        }
        final bytes = await arquivo.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          if (mounted) setState(() => _erro = 'Cada imagem deve ter até 5 MB.');
          return;
        }
        adicionadas.add(_FotoSelecionada(bytes, arquivo.name));
      }
      if (!mounted) return;
      setState(() {
        final vagas = 4 - _fotos.length;
        _fotos.addAll(adicionadas.take(vagas > 0 ? vagas : 0));
        _erro = adicionadas.length > vagas ? 'Limite de quatro imagens por post.' : null;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = 'Não foi possível selecionar imagens: $e');
    }
  }

  Future<void> _publicar() async {
    if (_enviando) return;
    final autor = AuthService.idUsuario;
    if (autor == null || !AuthService.logado) {
      setState(() => _erro = 'Entre na sua conta para publicar.');
      return;
    }
    if (_titulo.text.trim().isEmpty || _conteudo.text.trim().isEmpty) {
      setState(() => _erro = 'Preencha título e texto.');
      return;
    }
    setState(() { _enviando = true; _erro = null; });
    try {
      // O Web cria o post PRIMEIRO e só depois envia cada imagem.
      if (_idPostCriado == null) {
        final id = await _service.criarPostRetornandoId(Post(
          idUsuario: autor,
          titulo: _titulo.text.trim(),
          conteudo: _conteudo.text.trim(),
        ));
        if (!mounted) return;
        setState(() => _idPostCriado = id);
      }
      for (final foto in _fotos.where((f) => !f.enviada)) {
        await _service.enviarImagemDoPost(
          idPost: _idPostCriado!,
          bytes: foto.bytes,
          nomeArquivo: foto.nome,
        );
        foto.enviada = true;
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = _idPostCriado == null
          ? 'Falha ao criar post: $e. Confira o feed antes de tentar novamente.'
          : 'Post #$_idPostCriado foi criado, mas uma imagem falhou. '
            'Você pode tentar enviar novamente sem duplicar o post. Detalhes: $e';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nova publicação'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(onPressed: _enviando ? null : _publicar,
            child: const Text('Publicar', style: TextStyle(
              color: rosa, fontWeight: FontWeight.w800))),
          const SizedBox(width: 7),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const CircleAvatar(backgroundColor: Color(0xFFFFEAF1),
              child: Icon(Icons.person_outline, color: rosa)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AuthService.nomeUsuario ?? 'Você',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
                const Text('Compartilhe um momento com a comunidade',
                  style: TextStyle(fontSize: 12, color: cinza)),
              ])),
          ]),
          const SizedBox(height: 22),
          TextField(controller: _titulo, maxLength: 120,
            enabled: _idPostCriado == null,
            decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 10),
          TextField(controller: _conteudo, minLines: 5, maxLines: 8,
            enabled: _idPostCriado == null,
            decoration: const InputDecoration(
              hintText: 'O que você gostaria de compartilhar?',
              alignLabelWithHint: true)),
          const SizedBox(height: 14),
          if (_fotos.isNotEmpty) SizedBox(height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final foto = _fotos[i];
                return Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(14),
                    child: Image.memory(foto.bytes, width: 240, height: 210,
                      fit: BoxFit.cover)),
                  if (foto.enviada) const Positioned(left: 8, top: 8,
                    child: CircleAvatar(radius: 16, backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white, size: 18))),
                  if (_idPostCriado == null) Positioned(right: 8, top: 8,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(() => _fotos.removeAt(i)))),
                ]);
              },
            )),
          if (_fotos.isNotEmpty) const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _enviando || _idPostCriado != null || _fotos.length >= 4
              ? null : _escolherImagens,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_fotos.isEmpty ? 'Adicionar imagens'
              : 'Adicionar mais imagens (${_fotos.length}/4)'),
          ),
          if (_erro != null) Padding(
            padding: const EdgeInsets.only(top: 14),
            child: SelectableText(_erro!,
              style: const TextStyle(color: Color(0xFFC93659), fontSize: 13))),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _enviando ? null : _publicar,
            icon: _enviando
              ? const SizedBox(height: 18, width: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send_rounded),
            label: Text(_enviando ? 'Enviando...'
              : (_idPostCriado == null ? 'Publicar agora' : 'Reenviar imagens pendentes')),
          ),
        ]),
      )),
    );
  }
}
