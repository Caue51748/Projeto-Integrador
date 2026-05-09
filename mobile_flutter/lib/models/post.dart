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
      idPost: json['id_post'] ?? json['idPost'],
      idUsuario: json['id_usuario'] ?? json['idUsuario'],
      titulo: json['titulo'] ?? '',
      conteudo: json['conteudo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario, // Padrão que o Spring Boot geralmente lê
      'id_usuario': idUsuario, // Padrão backup para garantir
      'titulo': titulo,
      'conteudo': conteudo,
    };
  }
}