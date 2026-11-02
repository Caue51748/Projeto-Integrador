class Post {
  int? idPost;
  int? idUsuario;
  String titulo;
  String conteudo;
  String? imagemUrl;

  Post({this.idPost, this.idUsuario, required this.titulo,
    required this.conteudo, this.imagemUrl});

  static int? _id(dynamic raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    if (raw is Map) return _id(raw['idUsuario'] ?? raw['id'] ?? raw['idPost']);
    return null;
  }

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    idPost: _id(json['idPost'] ?? json['id_post'] ?? json['id']),
    idUsuario: _id(json['idUsuario'] ?? json['id_usuario'] ?? json['usuario']),
    titulo: (json['titulo'] ?? '').toString(),
    conteudo: (json['conteudo'] ?? '').toString(),
    imagemUrl: (json['imagemUrl'] ?? json['imagem_url'] ?? json['imagem'] ?? json['imageUrl'])?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'conteudo': conteudo,
    'idUsuario': idUsuario,
    if (imagemUrl != null && imagemUrl!.isNotEmpty) 'imagemUrl': imagemUrl,
  };
}
