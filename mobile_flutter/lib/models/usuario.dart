class Usuario {
  int? idUsuario;
  String nome;
  String email;
  String senha;
  String? username;
  String? bio;

  Usuario({
    this.idUsuario,
    required this.nome,
    required this.email,
    required this.senha,
    this.username,
    this.bio,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] ?? json['id_usuario'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      username: json['username'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nome': nome,
      'email': email,
      'senha': senha,
    };
    if (idUsuario != null) map['idUsuario'] = idUsuario;
    if (username != null) map['username'] = username;
    if (bio != null) map['bio'] = bio;
    return map;
  }
}