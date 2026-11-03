class Post {
  int? idPost;
  int? idUsuario;
  String titulo;
  String conteudo;
  String? imagemUrl;
  List<String> imagens;

  Post({
    this.idPost,
    this.idUsuario,
    required this.titulo,
    required this.conteudo,
    this.imagemUrl,
    this.imagens = const [],
  });

  static int? _id(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is Map) return _id(value['idUsuario'] ?? value['id'] ?? value['idPost']);
    return null;
  }

  static String? _caminho(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map) {
      return _caminho(value['url'] ?? value['imagemUrl'] ?? value['urlImagem'] ??
          value['caminho'] ?? value['caminhoArquivo'] ?? value['src']);
    }
    return null;
  }

  static List<String> _lerImagens(dynamic value) {
    if (value is! List) return const [];
    return value.map(_caminho).whereType<String>().toList();
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final principal = _caminho(json['imagemUrl'] ?? json['imagem_url'] ??
        json['imagem'] ?? json['imageUrl']);
    final multiplas = _lerImagens(json['imagens'] ?? json['imagensPost'] ??
        json['imagensUrls'] ?? json['fotos']);
    final unicas = <String>{
      if (principal != null) principal,
      ...multiplas,
    }.toList();
    return Post(
      idPost: _id(json['idPost'] ?? json['id_post'] ?? json['id']),
      idUsuario: _id(json['idUsuario'] ?? json['id_usuario'] ?? json['usuario']),
      titulo: (json['titulo'] ?? '').toString(),
      conteudo: (json['conteudo'] ?? '').toString(),
      imagemUrl: principal ?? (unicas.isNotEmpty ? unicas.first : null),
      imagens: unicas,
    );
  }

  // POST /posts cria somente a publicação; no Web, os arquivos são
  // enviados depois, já com o ID retornado pelo servidor.
  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'conteudo': conteudo,
    'idUsuario': idUsuario,
  };
}
