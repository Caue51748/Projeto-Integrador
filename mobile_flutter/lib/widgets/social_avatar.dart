import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Avatar único das telas sociais; usa a mesma URL que o feed.
class SocialAvatar extends StatelessWidget {
  final String nome;
  final String? foto;
  final double radius;
  const SocialAvatar({super.key, required this.nome, this.foto, this.radius = 23});

  @override
  Widget build(BuildContext context) {
    final url = ApiService.formatarUrlFotoPerfil(foto);
    Widget fallback() => Center(child: Text(
      nome.trim().isEmpty ? '?' : nome.trim()[0].toUpperCase(),
      style: TextStyle(fontWeight: FontWeight.w800,
        fontSize: radius * .75, color: const Color(0xFFEA3F74)),
    ));
    return ClipOval(child: Container(
      width: radius * 2, height: radius * 2,
      color: const Color(0xFFFFE7EF),
      child: url == null ? fallback() : Image.network(url,
        fit: BoxFit.cover, width: radius * 2, height: radius * 2,
        errorBuilder: (_, __, ___) => fallback()),
    ));
  }
}
