class Comentario {
  final int? idComentario;
  final String conteudo;
  final int idUsuario;
  final int idPost;

  Comentario({
    this.idComentario,
    required this.conteudo,
    required this.idUsuario,
    required this.idPost,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      idComentario: json['idComentario'],
      conteudo: json['conteudo'],
      idUsuario: json['idUsuario'],
      idPost: json['idPost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idComentario': idComentario,
      'conteudo': conteudo,
      'idUsuario': idUsuario,
      'idPost': idPost,
    };
  }
}