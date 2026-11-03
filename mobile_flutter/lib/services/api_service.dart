import 'auth_service.dart';

class ApiService {
  // Configure sem editar código:
  // Chrome + backend no mesmo PC: http://localhost:8080
  // Emulador Android + backend no PC: http://10.0.2.2:8080
  // Celular na mesma rede: http://IP_DO_PC:8080
  // Render: https://projeto-integrador-m4jn.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String usuarios = '$baseUrl/usuarios';
  static String posts = '$baseUrl/posts';
  static String comentarios = '$baseUrl/comentarios';
  static String comunidades = '$baseUrl/comunidades';
  static String eventos = '$baseUrl/api/eventos';

  static Map<String, String> get authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${AuthService.token}';
    }
    return headers;
  }

  static String? formatarUrlMidia(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final texto = valor.trim();
    if (texto.startsWith('https://') || texto.startsWith('http://')) return texto;
    if (texto.startsWith('/')) return '$baseUrl$texto';
    return '$baseUrl/$texto';
  }

  static String? formatarUrlFotoPerfil(String? fotoPerfil) {
    if (fotoPerfil == null || fotoPerfil.trim().isEmpty) return null;
    final foto = fotoPerfil.trim();
    if (foto.startsWith('http://') || foto.startsWith('https://')) return foto;
    if (foto.startsWith('uploads/')) return '$baseUrl/$foto';
    if (foto.startsWith('/google/drive/image/') ||
        foto.startsWith('google/drive/image/')) {
      final caminho = foto.startsWith('/') ? foto.substring(1) : foto;
      return '$baseUrl/$caminho';
    }
    return '$baseUrl/google/drive/image/$foto';
  }
}
