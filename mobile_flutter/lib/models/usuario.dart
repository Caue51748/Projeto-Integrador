class Usuario {
  final int? idUsuario;
  final String nome;
  final String email;
  final String senha;

  Usuario({
    this.idUsuario,
    required this.nome,
    required this.email,
    required this.senha,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }
}