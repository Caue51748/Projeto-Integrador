class Usuario {
  int? idUsuario;
  String nome;
  String email;
  String senha;

  Usuario({
    this.idUsuario,
    required this.nome,
    required this.email,
    required this.senha,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      // A mágica: se não achar 'idUsuario', tenta 'id_usuario'
      idUsuario: json['idUsuario'] ?? json['id_usuario'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idUsuario": idUsuario,
      "nome": nome,
      "email": email,
      "senha": senha,
    };
  }
}