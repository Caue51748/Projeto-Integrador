import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'feed_page.dart';
import 'usuarios_screen.dart';
import 'login_screen.dart'; // Mantendo seu fluxo original

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaAtual = 0;

  final paginas = [
    const FeedPage(),
    const UsuarioScreen(),
  ];

  void _selecionarPagina(int index) {
    setState(() => paginaAtual = index);
    Navigator.pop(context); // Fecha o menu lateral
  }

  void _fazerLogout() {
    AuthService.logado = false;
    AuthService.idUsuario = null;
    AuthService.nomeUsuario = null;
    setState(() {}); // Atualiza a tela para refletir o logout
    Navigator.pop(context); // Fecha o menu lateral
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SocialJoin"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1C23), // O azul/cinza bem escuro da sua imagem
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'SocialJoin',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 22, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            // Itens do Menu
            _buildMenuItem(0, Icons.grid_view_rounded, "Feed Geral"),
            _buildMenuItem(1, Icons.people_outline, "Usuários"),
            
            const Spacer(),
            
            // Rodapé do Menu (Baseado 100% na sua imagem)
            if (AuthService.logado) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      children: [
                        const TextSpan(text: "Logado como: "),
                        TextSpan(
                          text: AuthService.nomeUsuario ?? 'Usuário',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA3F74),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _fazerLogout,
                    child: const Text("Sair do Sistema", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA3F74),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: const Text("Fazer Login", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
      body: paginas[paginaAtual],
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    bool isSelected = paginaAtual == index;
    return InkWell(
      onTap: () => _selecionarPagina(index),
      child: Container(
        color: isSelected ? const Color(0xFFEA3F74) : Colors.transparent, // Destaque rosa da imagem
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white, 
                fontSize: 15, 
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}