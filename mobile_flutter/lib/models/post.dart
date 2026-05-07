class Post {

  int? idPost;

  String titulo;

  String conteudo;

  int idUsuario;

  Post({

    this.idPost,

    required this.titulo,

    required this.conteudo,

    required this.idUsuario,
  });

  factory Post.fromJson(
      Map<String, dynamic> json,
      ) {

    return Post(

      idPost: json['idPost'],

      titulo: json['titulo'],

      conteudo: json['conteudo'],

      idUsuario: json['idUsuario'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'idPost': idPost,

      'titulo': titulo,

      'conteudo': conteudo,

      'idUsuario': idUsuario,
    };
  }
}