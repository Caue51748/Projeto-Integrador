class AuthService {
  static bool logado = false;
  static int? idUsuario;
  static String? nomeUsuario;
  static String? emailUsuario;
  static String? username;
  static String? bio;

  static void fazerLogin({
    required int idUsuario,
    required String nome,
    required String email,
    String? username,
    String? bio,
  }) {
    AuthService.logado = true;
    AuthService.idUsuario = idUsuario;
    AuthService.nomeUsuario = nome;
    AuthService.emailUsuario = email;
    AuthService.username = username;
    AuthService.bio = bio;
  }

  static void fazerLogout() {
    logado = false;
    idUsuario = null;
    nomeUsuario = null;
    emailUsuario = null;
    username = null;
    bio = null;
  }
}