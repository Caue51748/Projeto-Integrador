class Post {
  int? idPost;
  int? idUsuario;
  String titulo;
  String conteudo;

  Post({
    this.idPost,
    this.idUsuario,
    required this.titulo,
    required this.conteudo,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      idPost: json['idPost'] ?? json['id_post'],
      idUsuario: json['idUsuario'] ?? json['id_usuario'],
      titulo: json['titulo'] ?? '',
      conteudo: json['conteudo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Aqui está o segredo: enviamos APENAS os mesmos nomes das variáveis do Post.java
    return {
      'titulo': titulo,
      'conteudo': conteudo,
      'idUsuario': idUsuario,
    };
  }
}