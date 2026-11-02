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

class _CreatePostPageState extends State<CreatePostPage> {
  final _titulo = TextEditingController();
  final _conteudo = TextEditingController();
  Uint8List? _imagemBytes;
  String? _nomeImagem;
  bool _enviando = false;
  String? _erro;
  static const violeta = Color(0xFFEA3F74);

  @override
  void dispose() { _titulo.dispose(); _conteudo.dispose(); super.dispose(); }

  Future<void> _escolherImagem() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery,
        maxWidth: 1600, imageQuality: 82);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        setState(() => _erro = 'A imagem deve ter até 5 MB.'); return;
      }
      if (!mounted) return;
      setState(() { _imagemBytes = bytes; _nomeImagem = file.name; _erro = null; });
    } catch (e) { if (mounted) setState(() => _erro = 'Não foi possível selecionar a imagem: $e'); }
  }

  Future<void> _publicar() async {
    final id = AuthService.idUsuario;
    if (id == null || !AuthService.logado) {
      setState(() => _erro = 'Entre na sua conta para publicar.'); return;
    }
    if (_titulo.text.trim().isEmpty || _conteudo.text.trim().isEmpty) {
      setState(() => _erro = 'Preencha o título e o texto da publicação.'); return;
    }
    setState(() { _enviando = true; _erro = null; });
    try {
      final service = PostService();
      String? imagemUrl;
      if (_imagemBytes != null) {
        imagemUrl = await service.enviarImagem(
          bytes: _imagemBytes!, nomeArquivo: _nomeImagem ?? 'publicacao.jpg');
      }
      await service.criarPostOuFalhar(Post(
        titulo: _titulo.text.trim(), conteudo: _conteudo.text.trim(),
        idUsuario: id, imagemUrl: imagemUrl,
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _enviando = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(title: const Text('Nova publicação'), actions: [
      Padding(padding: const EdgeInsets.only(right: 12), child: TextButton(
        onPressed: _enviando ? null : _publicar,
        child: Text('Publicar', style: TextStyle(color: _enviando ? Colors.grey : violeta,
          fontWeight: FontWeight.w800)),
      )),
    ]),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          CircleAvatar(backgroundColor: const Color(0xFFE9E6FF),
            child: const Icon(Icons.person_rounded, color: violeta)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AuthService.nomeUsuario ?? 'Usuário',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const Text('Compartilhe algo com a comunidade',
              style: TextStyle(fontSize: 12, color: Color(0xFF71788A))),
          ]),
        ]),
        const SizedBox(height: 22),
        TextField(controller: _titulo, maxLength: 120,
          decoration: const InputDecoration(hintText: 'Dê um título à publicação')),
        const SizedBox(height: 12),
        TextField(controller: _conteudo, maxLines: 7, minLines: 5,
          decoration: const InputDecoration(hintText: 'O que está acontecendo?', alignLabelWithHint: true)),
        const SizedBox(height: 14),
        if (_imagemBytes != null) ...[
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
            Image.memory(_imagemBytes!, fit: BoxFit.cover, width: double.infinity, height: 230),
            Positioned(top: 10, right: 10, child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => setState(() { _imagemBytes = null; _nomeImagem = null; }),
              icon: const Icon(Icons.close_rounded))),
          ])),
          const SizedBox(height: 14),
        ],
        OutlinedButton.icon(onPressed: _enviando ? null : _escolherImagem,
          icon: const Icon(Icons.add_photo_alternate_outlined), label: Text(
            _imagemBytes == null ? 'Adicionar foto da galeria' : 'Trocar imagem')),
        if (_erro != null) ...[
          const SizedBox(height: 12),
          Text(_erro!, style: const TextStyle(color: Color(0xFFD93556), fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 22),
        FilledButton.icon(onPressed: _enviando ? null : _publicar,
          icon: _enviando ? const SizedBox(width: 18,height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded),
          label: Text(_enviando ? 'Publicando...' : 'Publicar agora')),
      ]),
    ),
  );
}
