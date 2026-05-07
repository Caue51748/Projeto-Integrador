class Post {
  final int? idPost;
  final String titulo;
  final String conteudo;
  final int idUsuario;
  final int? idComunidade;

  Post({
    this.idPost,
    required this.titulo,
    required this.conteudo,
    required this.idUsuario,
    this.idComunidade,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      idPost: json['idPost'],
      titulo: json['titulo'],
      conteudo: json['conteudo'],
      idUsuario: json['idUsuario'],
      idComunidade: json['idComunidade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPost': idPost,
      'titulo': titulo,
      'conteudo': conteudo,
      'idUsuario': idUsuario,
      'idComunidade': idComunidade,
    };
  }
}